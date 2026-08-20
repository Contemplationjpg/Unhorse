class_name Player
extends Node

@export var claw : Claw


func _ready() -> void:
	return

func _physics_process(delta: float) -> void:
	if claw:
		claw.claw_physics_process(delta)

func _process(delta: float) -> void:
	if claw:
		claw.claw_process(delta)	

func set_claw(c : Claw):
	claw = c
