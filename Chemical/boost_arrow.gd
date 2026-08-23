class_name BoostArrow
extends Node2D

@export var area : Area2D
@export var sprite : AnimatedSprite2D
@export var boost_strength : float = 2000

func _ready() -> void:
	area.body_entered.connect(boost)
	sprite.play("default")



func boost(body : Node2D):
	var loot = body as Loot
	if loot:
		var pointing_dir : Vector2 = Vector2.UP.rotated(global_rotation)
		loot.apply_central_impulse(pointing_dir * boost_strength)


