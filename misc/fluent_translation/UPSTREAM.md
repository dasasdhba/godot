Extension upstream: https://github.com/RedMser/godot-fluent-translation
Revision: 3d0674c808a0a4e936481fd4f94a10cfb68fc684
Engine upstream: https://github.com/RedMser/godot/tree/fluent-translation
Engine comparison base: 77dcf97d82cbfe4e4615475fa52ca03da645dbd8

Local adaptations:
- Port engine argument forwarding to Godot 4.7 translation domains.
- Retain native C++ context overloads; update scripting API and extraction.
- Defer translation resources/remaps until scene extension initialization.
- Update godot-rust to 0.5.5 using the custom engine API.
- Adapt collections, argument passing, and initialization to current bindings.
- Register a tool-mode loader in the editor; enable threaded binding support and Fluent's concurrent memoizer.
- Update C# translation extraction, including named arguments and Atr calls.
- Include a reproducible build script and startup/runtime verification project.
