extends Control

func _ready() -> void:
	visible = false

func _on_main_menu_pressed() -> void:
	if not get_tree().get_current_scene().name == "TitleScreen":
		get_tree().change_scene_to_file("res://Scenes/TitleScreen.tscn")
	else:
		visible = false
