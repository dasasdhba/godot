extends SceneTree

var failures := 0

func check_equal(actual: Variant, expected: Variant, description: String) -> void:
	if actual != expected:
		push_error("%s: expected %s, got %s" % [description, expected, actual])
		failures += 1
	else:
		print("PASS: ", description)

func _initialize() -> void:
	# These resources must already be loaded from Project Settings before scripts run.
	check_equal(TranslationServer.get_loaded_locales().has("zh_CN"), true, "startup .ftl loading")
	TranslationServer.set_locale("en")
	check_equal(tr("hello", {"name": "Godot"}), "Hello, Godot!", "tr variables")
	check_equal(tr("hello", {"name": "Godot"}, "title"), "Welcome, Godot", "message attribute")
	check_equal(tr("items", {"count": 1}), "One item", "Fluent singular selector")
	check_equal(tr("items", {"count": 5}), "5 items", "Fluent plural selector")
	check_equal(tr("product"), "Powered by Godot Moon", "term reference")
	check_equal(tr("missing-key", {"name": "Godot"}), "missing-key", "missing key")
	check_equal(TranslationServer.translate("hello", {"name": "Server"}), "Hello, Server!", "server arguments")
	var typed_args: Dictionary[String, String] = {"name": "Typed"}
	check_equal(tr("hello", typed_args), "Hello, Typed!", "typed argument dictionary")
	check_equal(ResourceLoader.load_threaded_request("res://threaded.en.ftl"), OK, "background load request")
	var threaded := ResourceLoader.load_threaded_get("res://threaded.en.ftl") as Translation
	check_equal(threaded != null, true, "background resource load")
	if threaded:
		check_equal(threaded.get_message("threaded", {"name": "Godot"}), "Background, Godot", "background loaded formatting")

	TranslationServer.set_locale("zh_CN")
	check_equal(tr("hello", {"name": "Godot"}), "你好，Godot！", "Chinese locale and underscore region")
	check_equal(tr("fallback-only", {"name": "Godot"}), "English fallback, Godot", "fallback preserves arguments")

	var domain := TranslationServer.get_or_add_domain("fluent-demo")
	domain.add_translation(load("res://messages.en.ftl"))
	check_equal(domain.translate("hello", {"name": "Domain"}), "Hello, Domain!", "custom domain fallback")
	domain.set_locale_override("en")
	check_equal(domain.translate("hello", {"name": "Domain"}, "title"), "Welcome, Domain", "custom domain attribute")
	var node := Node.new()
	node.set_translation_domain("fluent-demo")
	check_equal(node.atr("hello", {"name": "Node"}), "Hello, Node!", "atr arguments")
	node.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	check_equal(node.atr("hello", {"name": "Node"}), "hello", "auto translate disabled")
	node.set_message_translation(false)
	check_equal(node.tr("hello", {"name": "Node"}), "hello", "message translation disabled")
	node.free()
	TranslationServer.remove_domain("fluent-demo")

	var inline_translation := TranslationFluent.new()
	inline_translation.locale = "pt_BR"
	check_equal(inline_translation.append_from_text("inline = Olá, { $name }!\ncustom = { UPPER($name) }"), OK, "inline regional locale")
	check_equal(inline_translation.add_function("UPPER", func(positional: Array, _named: Dictionary): return str(positional[0]).to_upper()), OK, "register custom function")
	check_equal(inline_translation.get_message("inline", {"name": "Godot"}), "Olá, Godot!", "resource get_message")
	check_equal(inline_translation.get_message("custom", {"name": "godot"}), "GODOT", "custom function")
	var ordinary := Translation.new()
	ordinary.add_message("hello", "Bonjour", "greeting")
	check_equal(ordinary.get_message("hello", {}, "greeting"), "Bonjour", "ordinary translation context")
	ordinary.add_plural_message("item", PackedStringArray(["item", "items"]))
	check_equal(ordinary.get_plural_message("item", "items", 2), "items", "ordinary plural API")
	print("FLUENT VERIFICATION: ", "PASS" if failures == 0 else "FAIL (%d)" % failures)
	quit(0 if failures == 0 else 1)
