class_name Scorekeeper
extends Node

@export var info_hud : RichTextLabel
@export var score_box : RichTextLabel


@onready var gm : ChemicalGameManager = ChemicalGameManager

var last_point_value : int = 0


func _ready() -> void:
	update_ui()
	gm.on_any_update.connect(update_ui)
	gm.on_loot_scored.connect(on_loot_score_detected)


func update_ui():
	#this bit here is temporary until we have actual ui set up
	var res : String
	res = "points: " + str(gm.points) + "\n"
	res += "plays: " + str(gm.plays) + "\n"
	res += "spins: " + str(gm.spins) + "\n"
	info_hud.text = res

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug"): #hiiiiiii
		#gm.gain_points(15)
		gm.gain_plays(3)
		#return

#for now just moves a textbox to the location of score, but later will spawn a textbox that destroys itself after a little
#rn this can only keep track of one instance of scoring at a time and doesn't ever go away
func on_loot_score_detected(position : Vector2, amount : int):
	print("Loot just scored " + str(amount) + " points at screen position " + str(position))
	score_box.text = str("+" + str(amount))
	score_box.global_position = position
