param(
    [Parameter(Mandatory = $true)][string]$GodotBin,
    [string]$CargoBin = "cargo",
    [string]$ProjectDir
)
$ErrorActionPreference = "Stop"
$env:GDRUST_GODOT_BIN = (Resolve-Path -LiteralPath $GodotBin).Path
$godotRunner = $env:GDRUST_GODOT_BIN
# Watch the actual editor binary: the console launcher can remain unchanged after rebuilds.
if ($env:GDRUST_GODOT_BIN.EndsWith('.console.exe')) {
    $editorBinary = $env:GDRUST_GODOT_BIN.Replace('.console.exe', '.exe')
    if (Test-Path -LiteralPath $editorBinary) { $env:GDRUST_GODOT_BIN = $editorBinary }
} elseif ($godotRunner.EndsWith('.exe')) {
    $consoleRunner = $godotRunner.Substring(0, $godotRunner.Length - 4) + '.console.exe'
    if (Test-Path -LiteralPath $consoleRunner) { $godotRunner = $consoleRunner }
}
Push-Location (Join-Path $PSScriptRoot "rust")
try {
    & $CargoBin build --locked --release --features forked-godot
    if ($LASTEXITCODE -ne 0) { throw "Fluent extension build failed." }
    $metadataJson = & $CargoBin metadata --locked --no-deps --format-version 1
    if ($LASTEXITCODE -ne 0) { throw "Unable to locate Cargo build output." }
    $targetDirectory = ($metadataJson | ConvertFrom-Json).target_directory
    $addon = Join-Path $PSScriptRoot "demo/addons/godot-fluent-translation"
    New-Item -ItemType Directory -Force -Path $addon | Out-Null
    Copy-Item -LiteralPath (Join-Path $targetDirectory "release/godot_fluent_translation.dll") -Destination $addon
    if ($ProjectDir) {
        $destination = Join-Path (Resolve-Path -LiteralPath $ProjectDir).Path "addons/godot-fluent-translation"
        New-Item -ItemType Directory -Force -Path $destination | Out-Null
        Copy-Item -Path (Join-Path $addon "*") -Destination $destination -Force
    }
} finally { Pop-Location }
& $godotRunner --headless --path (Join-Path $PSScriptRoot "demo") --editor --import
if ($LASTEXITCODE -ne 0) { throw "Demo import failed." }
$verification = & $godotRunner --headless --path (Join-Path $PSScriptRoot "demo") --script res://verify.gd --quit-after 300 2>&1
$verification | Write-Output
if ($LASTEXITCODE -ne 0 -or ($verification -join "`n") -notmatch 'FLUENT VERIFICATION: PASS') {
    throw "Fluent verification failed."
}
