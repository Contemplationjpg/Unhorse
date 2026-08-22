extends Control

@export var reset_button : Button
@export var popup : Panel

@export var confirm_button : Button
@export var decline_button : Button

@onready var gm : ChemicalGameManager = ChemicalGameManager

func _ready() -> void:
	popup.set_deferred("visible", false)
	reset_button.button_up.connect(open_popup)
	decline_button.button_up.connect(close_popup)
	confirm_button.button_up.connect(reset_save_data)

	
func open_popup():
	popup.set_deferred("visible", true)

func close_popup():
	popup.set_deferred("visible", false)

func reset_save_data():
	gm.reset_save_file.emit()
	popup.set_deferred("visible", false)
