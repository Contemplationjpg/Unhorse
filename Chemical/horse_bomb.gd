class_name HorseBomb
extends GPUParticles2D

@export var area : Area2D

@export var do_knockback_on_detonate : bool = false
@export var destroy_after_detonate : bool = true
@export var impulse_amount : float = 500

var loot_in_range : Array[Loot] = []

var exploding : bool = false

func _ready():
	emitting = false
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exit)
	return

func explode():
	if not exploding:
		exploding = true
		bump()
		emitting = true
		await finished
		queue_free()


func bump():
	#print("bump")
	for i in loot_in_range:
		if is_instance_valid(i):
			var push_dir : Vector2 = (i.global_position - global_position).normalized()
			i.apply_central_impulse(push_dir * impulse_amount)
	


func _on_body_entered(body : Node2D):
	print("body entered")
	var other_loot = body as Loot
	if other_loot:
		if loot_in_range.find(other_loot) == -1: #find() returns -1 if nothing found
			loot_in_range.append(other_loot)

func _on_body_exit(body : Node2D):
	#print("body exited")
	var other_loot = body as Loot
	if other_loot:
		if not loot_in_range.find(other_loot) == -1:#find() returns -1 if nothing found
			loot_in_range.erase(other_loot)
