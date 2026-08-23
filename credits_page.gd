extends Control

@export var open_button : Button
@export var close_button : Button
@export var credits : Panel

func _ready() -> void:
	credits.set_deferred("visible", false)
	open_button.pressed.connect(open_credits)
	close_button.pressed.connect(close_credits)

func open_credits():
	credits.set_deferred("visible", true)

func close_credits():
	credits.set_deferred("visible", false)

