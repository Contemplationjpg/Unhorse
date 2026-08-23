extends Node2D

@export var settings : Control

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("menu") and settings.visible == false:
		settings.visible = true
	elif Input.is_action_just_pressed("menu") and settings.visible == true:
		settings.visible = false
