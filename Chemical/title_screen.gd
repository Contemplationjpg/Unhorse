extends Control

@export var version_label : RichTextLabel
@export var curtain : TextureRect
@export var unhorse_sound : AudioStreamPlayer
@export var music : AudioStreamPlayer

@onready var gm : ChemicalGameManager = ChemicalGameManager


signal fully_black()
signal start_game()

var fading : bool = false
var fade_time : float = 1

var post_neigh : float = 0.5
var post_neigh_timer : float = 0

@onready var volume_down_per_second = (80+music.volume_db)/fade_time

func _ready() -> void:
	version_label.text = str("Version: " + str(gm.VERSION))
	curtain.self_modulate.a = 0
	curtain.set_deferred("visible", false)

func _on_play_pressed() -> void:
	if fading:
		return
	fade_to_black()
	
	await fully_black
	unhorse_sound.play()
	await unhorse_sound.finished
	post_neigh_timer = post_neigh
	
	await start_game
	
	get_tree().change_scene_to_file("res://Scenes/chemical.tscn")

func _process(delta: float) -> void:
	if post_neigh_timer > 0:
		post_neigh_timer -= delta
		if post_neigh_timer <= 0:
			start_game.emit()

	if fading:
		if curtain.self_modulate.a < 1:
			curtain.self_modulate.a += fade_time*delta
			music.volume_db -= volume_down_per_second
			print(curtain.self_modulate.a)
		else:
			music.volume_db = -80
			fully_black.emit()
	
	


func fade_to_black():
	curtain.self_modulate.a = 0
	curtain.set_deferred("visible", true)
	fading = true

func _on_settings_pressed() -> void:
	if fading:
		return
	$Settings.visible = true


func _on_exit_pressed() -> void:
	if fading:
		return
	get_tree().quit()
