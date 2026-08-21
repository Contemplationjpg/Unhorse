class_name Scorekeeper
extends Node

@export var points_label : RichTextLabel
@export var plays_label : RichTextLabel
@export var spins_label : RichTextLabel
@export var screen_canvas : CanvasLayer
@export var ui_canvas : CanvasLayer
@export var float_text_scene : PackedScene
@export var float_text_rand_radius : float = 10


@onready var gm : ChemicalGameManager = ChemicalGameManager

var last_point_value : int = 0


func _ready() -> void:
	update_ui()
	gm.on_any_update.connect(update_ui)
	gm.on_loot_scored.connect(on_loot_score_detected)
	gm.on_loot_bonus_update.connect(on_loot_bonus_update_detected)
	
	gm.on_gain_points.connect(spawn_floating_text_ui_points)
	gm.on_gain_plays.connect(spawn_floating_text_ui_plays)
	gm.on_gain_spins.connect(spawn_floating_text_ui_spins)

	gm.on_spend_points.connect(spawn_floating_text_ui_points_loss)
	gm.on_spend_plays.connect(spawn_floating_text_ui_plays_loss)
	gm.on_spend_spins.connect(spawn_floating_text_ui_spins_loss)


func update_ui():
	var res : String
	res = str(gm.points)
	points_label.text = res
	res = str(gm.plays)
	plays_label.text = res
	res = str(gm.spins) 
	spins_label.text = res

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug"): #hiiiiiii
		#gm.gain_points(15)
		#gm.gain_plays(3)
		return

#spawning text around the screen at variable locations-------------------------------------

#for now just moves a textbox to the location of score, but later will spawn a textbox that destroys itself after a little
#rn this can only keep track of one instance of scoring at a time and doesn't ever go away
func on_loot_score_detected(position : Vector2, amount : int):
	#print("Loot just scored " + str(amount) + " points at screen position " + str(position))
	#score_box.text = str("+" + str(amount))
	#score_box.global_position = position
	spawn_floating_text_score(position, str("+" + str(amount)))

func on_loot_bonus_update_detected(position : Vector2, bonus : float):
	spawn_floating_text_score(position, str("x" + str(bonus)), 0.5)
		

func spawn_floating_text_score(position : Vector2, message : String, time : float = 2):
	if float_text_scene:
		var float_text : FloatText = float_text_scene.instantiate()
		var dir
		if randi_range(0,1) == 0:
			dir = Vector2(1,-1)
		else:
			dir = Vector2(-1,-1)
		float_text.prime_text(message, position, float_text_rand_radius, time, dir, 10, Color.WHITE)
		screen_canvas.add_child(float_text)



#for resource gain-------------------------------------------------------

func spawn_floating_text_ui_points(point_gain : int):
	if float_text_scene:
		var float_text : FloatText = float_text_scene.instantiate()
		float_text.prime_text(str("+" + str(point_gain)),points_label.global_position + Vector2(+40,0),15,2,Vector2(1,-1),20)
		ui_canvas.add_child(float_text)
		return

func spawn_floating_text_ui_plays(play_gain : int):
	if float_text_scene:
		var float_text : FloatText = float_text_scene.instantiate()
		float_text.prime_text(str("+" + str(play_gain)),plays_label.global_position + Vector2(+40,0),10,2,Vector2(1,-1),15)
		ui_canvas.add_child(float_text)

func spawn_floating_text_ui_spins(spin_gain : int):
	if float_text_scene:
		var float_text : FloatText = float_text_scene.instantiate()
		float_text.prime_text(str("+" + str(spin_gain)),spins_label.global_position + Vector2(+40,0),10,2,Vector2(1,-1),15)
		ui_canvas.add_child(float_text)



#for resource loss------------------------------------

func spawn_floating_text_ui_points_loss(point_loss : int):
	if float_text_scene:
		var float_text : FloatText = float_text_scene.instantiate()
		float_text.prime_text(str("-" + str(point_loss)),points_label.global_position + Vector2(+40,0),15,2,Vector2(-1,-1),20,Color.RED)
		ui_canvas.add_child(float_text)
		return

func spawn_floating_text_ui_plays_loss(play_loss : int):
	if float_text_scene:
		var float_text : FloatText = float_text_scene.instantiate()
		float_text.prime_text(str("-" + str(play_loss)),plays_label.global_position + Vector2(+40,0),10,2,Vector2(-1,-1),15, Color.RED)
		ui_canvas.add_child(float_text)

func spawn_floating_text_ui_spins_loss(spin_loss : int):
	if float_text_scene:
		var float_text : FloatText = float_text_scene.instantiate()
		float_text.prime_text(str("-" + str(spin_loss)),spins_label.global_position + Vector2(+40,0),10,2,Vector2(-1,-1),15,Color.RED)
		ui_canvas.add_child(float_text)



		
	
