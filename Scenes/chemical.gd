extends Node2D


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("menu") and $Settings.visible == false:
		$Settings.visible = true
	elif Input.is_action_just_pressed("menu") and $Settings.visible == true:
		$Settings.visible = false
