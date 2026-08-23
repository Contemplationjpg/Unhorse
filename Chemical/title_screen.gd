extends Control

@export var version_label : RichTextLabel
@onready var gm : ChemicalGameManager = ChemicalGameManager

func _ready() -> void:
	version_label.text = str("Version: " + str(gm.VERSION))

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/chemical.tscn")


func _on_settings_pressed() -> void:
	$Settings.visible = true


func _on_exit_pressed() -> void:
	get_tree().quit()
