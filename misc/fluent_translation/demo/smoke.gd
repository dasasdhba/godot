extends Node

func _ready() -> void:
	TranslationServer.set_locale("zh_CN")
	var message := tr("hello", {"name": "Godot"})
	print(message)
	if message != "你好，Godot！":
		push_error("Fluent exported project verification failed")
		get_tree().quit(1)
	else:
		print("FLUENT PROJECT: PASS")
		get_tree().quit()
