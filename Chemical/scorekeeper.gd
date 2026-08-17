class_name Scorekeeper
extends Node

@onready var gm : ChemicalGameManager = ChemicalGameManager
@onready var text_box : RichTextLabel = $RichTextLabel

func _ready() -> void:
	update_ui()
	gm.on_any_update.connect(update_ui)


func update_ui():
	#this bit here is temporary until we have actual ui set up
	var res : String
	res = "points: " + str(gm.points) + "\n"
	res += "plays: " + str(gm.plays) + "\n"
	res += "spins: " + str(gm.spins) + "\n"
	text_box.text = res

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug"): #hiiiiiii
		#gm.gain_points(15)
		gm.gain_plays(3)
		#return
