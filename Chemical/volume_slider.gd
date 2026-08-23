extends HSlider

@export var bus_name: String

var gm: ChemicalGameManager = ChemicalGameManager

var bus_index: int

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	
	value = gm.get_music_volumes(bus_index)
	gm.save_loaded.connect(_on_save_loaded)
	_on_save_loaded()


func _on_value_changed(value: float) -> void:
	#converts audio slider value to decibels
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	
	gm.save_music_volumes(bus_index, value)
	gm.on_any_update.emit()
	
	
func _on_save_loaded():
	value = gm.get_music_volumes(bus_index)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
