# Fluent translations for Godot Moon

This directory carries the project-side Fluent extension adapted to this engine's
4.7 API. It is based on [RedMser/godot-fluent-translation](https://github.com/RedMser/godot-fluent-translation)
and the engine API changes from [RedMser's Fluent fork](https://github.com/RedMser/godot/tree/fluent-translation).
The upstream MIT license is retained in `LICENSE`.

## 在项目中使用

1. 用本仓库修改后的编辑器打开项目。
2. 将 `demo/addons/godot-fluent-translation` 复制到项目的 `addons` 下。
   这是 GDExtension，无需在 Plugins 页面启用。首次复制后重启编辑器。
3. 创建 `messages.en.ftl`、`messages.zh_CN.ftl` 等文件；文件名或父目录需要包含语言标识。
4. 在 Project Settings → Localization → Translations 中添加 `.ftl` 文件。
   文件选择器需要时可切换到 All Files。
5. 使用 `TranslationServer.set_locale("zh_CN")` 切换语言。

```ftl
-brand = Godot Moon
hello = 你好，{ $name }！
    .title = 欢迎，{ $name }
items = { $count ->
    [one] One item
   *[other] { $count } items
    }
product = Powered by { -brand }
```

```gdscript
tr("hello", {"name": "Godot"})
tr("hello", {"name": "Godot"}, "title") # Fluent attribute
tr("items", {"count": 5})               # Fluent controls plural rules
atr("hello", {"name": "Godot"})         # Respects auto_translate_mode
TranslationServer.translate("hello", {"name": "Godot"})
```

也支持 `TranslationFluent.new()`、`append_from_text()`、`add_function()`，以及
`TranslationServer.get_or_add_domain()` 创建的独立翻译域。示例见 `demo/verify.gd`。
无需把字典编码到消息 ID，也无需启用 `parse_args_in_message`。

C# 在重新生成和构建 GodotSharp 后使用同样的参数顺序：

```csharp
Tr("hello", new Godot.Collections.Dictionary { ["name"] = "Godot" });
Tr("hello", new Godot.Collections.Dictionary { ["name"] = "Godot" }, "title");
```

## API 兼容性

脚本接口与 Fluent fork 一致：`tr`、`atr`、`translate`、`get_message` 的参数为
`(message, args = {}, context = "")`。原有 `tr("message", "context")` 等调用
必须改为 `tr("message", {}, "context")`。C++ 的原有二参数上下文调用通过重载保留。
普通 Translation、CSV/PO 翻译和 `tr_n` / `translate_plural` 继续使用原有翻译规则；
Fluent 的复数选择请使用 `tr("key", {"count": n})`。

`Translation._get_message` 虚方法增加了 Dictionary 参数。依赖旧签名的自定义
Translation 子类和二进制扩展需要适配并重新构建。这个扩展的 DLL 必须使用本引擎
生成的 API 构建，不能与官方 Godot 或上游旧版 fork 的 DLL 混用。

## 重新构建扩展（Windows x86_64）

需要 Rust 1.94+ 和 Visual Studio C++ Build Tools。依赖版本由 `rust/Cargo.lock` 固定。
引擎编译完成后，从仓库根目录运行：

```powershell
./misc/fluent_translation/build.ps1 -GodotBin ./bin/godot.windows.editor.x86_64.mono.console.exe
# 可选：同时安装到指定项目
./misc/fluent_translation/build.ps1 -GodotBin ./bin/godot.windows.editor.x86_64.mono.console.exe -ProjectDir F:/path/to/project
```

`-CargoBin` 可指定 cargo 可执行文件路径。构建使用本地引擎的真实 API，随后导入并运行
`demo/verify.gd`；成功时输出 `FLUENT VERIFICATION: PASS`。
引擎 API 发生变化后，需要重新构建扩展。其他平台需要用对应的 Rust target 构建动态库，
并在 `.gdextension` 中添加库路径；本目录附带的二进制仅针对 Windows x86_64。

## 实现位置

变量字典沿 `Object/Node → TranslationServer/TranslationDomain → Translation._get_message`
传递。项目翻译资源与语言资源重映射在 Scene 级 GDExtension 初始化后加载，以确保
扩展已注册 `.ftl` 加载器。GDScript 翻译提取器读取第 1 个参数作为 ID、第 3 个参数作为
上下文，忽略运行时变量字典。引擎测试在 `tests/core/string/test_translation_server.cpp`。
C# 翻译提取器同样忽略变量字典，并支持命名的 `message` / `context` 参数。

FTL 解析、格式化、语言选择规则和自定义函数来自配套 Rust 扩展。扩展保留上游场景
提取器及导出时移除注释等功能。

