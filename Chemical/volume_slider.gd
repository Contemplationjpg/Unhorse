extends HSlider

@export var bus_name: String

var gm: ChemicalGameManager = ChemicalGameManager

var bus_index: int

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	
func _on_value_changed(value: float) -> void:
	#converts audio slider value to decibels
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	
	gm.save_music_volumes(bus_index, value)
	
	
	
