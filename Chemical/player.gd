class_name Player
extends Node

@export var claw : Claw

@onready var gm : ChemicalGameManager = ChemicalGameManager

func _ready() -> void:
	gm.send_claw.connect(get_claw)
	return

func _physics_process(delta: float) -> void:
	if claw:
		claw.claw_physics_process(delta)

func _process(delta: float) -> void:
	if claw:
		claw.claw_process(delta)
	#if Input.is_action_just_pressed("debug") and gm.points < 100:
		#gm.gain_points(100)

func set_claw(c : Claw):
	claw = c


func get_claw():
	if claw:
		print("sending claw")
		gm.send_claw.emit(claw)
