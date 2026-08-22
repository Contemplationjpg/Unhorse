class_name Bumper
extends RigidBody2D

@export_category("Bumper Setup")
@export var sprite : AnimatedSprite2D
@export var extend_area : Area2D
@export var extend_coll : CollisionShape2D
@export var bump_counter : RichTextLabel
@export var pilot_sprite : Sprite2D

@export_category("Bumper Stats")
@export var max_velocity : float = 500
@export var impulse_amount : float = 400
@export var extend_time : float = 1
@export var point_yield_after_destruction : int = 1000

@export var max_bumps : int = 20

@export var final_blink_speed : float = 0.5

signal just_bumped()
signal extend_end()

var bumps : int = 0
var bump_limit_reached : bool = false

var loot_in_range : Array[Loot] = []

var extended : bool = false

var extend_time_timer : float = 0
var blink_timer : float = 0

@onready var gm : ChemicalGameManager = ChemicalGameManager

func _ready() -> void:
	update_bump_counter()
	extend_area.body_entered.connect(_on_body_entered)
	extend_area.body_exited.connect(_on_body_exit)
	body_entered.connect(activate_bump)
	just_bumped.connect(on_bump)


func _process(delta: float) -> void:
	if extend_time_timer > 0:
		extend_time_timer -= delta
	if blink_timer > 0:
		blink_timer -= delta

	if extended:
		sprite.play("big")
	else:
		sprite.play("small")

	if extend_time_timer <= 0:
		extended = false
		extend_end.emit()
	if max_bumps > 0:
		bump_counter.set_deferred("visible", true)
		if bumps >= (max_bumps-1): #start blinking if about to end
			if bump_limit_reached:
				sprite.self_modulate.s = 1
				sprite.self_modulate.v = 1
			if blink_timer <= 0:
				sprite.self_modulate.s = 1
				if sprite.self_modulate.v == 0:
					sprite.self_modulate.v = 1
				else:
					sprite.self_modulate.v = 0
				blink_timer = final_blink_speed
		sprite.self_modulate.s = (float(bumps)/(max_bumps-1))
	else:
		bump_counter.set_deferred("visible", false)


	bump_counter.global_position = (global_position - Vector2(bump_counter.size.x/2, bump_counter.size.y/2))
	pilot_sprite.global_position = global_position

func _physics_process(delta: float) -> void:
	
	limit_velocity()

	if extended:
		extend_coll.disabled = false
	else:
		extend_coll.disabled = true

func limit_velocity():
	if linear_velocity.length() > max_velocity:
		var new_velocity = linear_velocity.normalized() * max_velocity
		linear_velocity = new_velocity


#managing bumping------------------------------------------------------------

func on_bump():
	if bump_limit_reached:
		return
	bumps+=1
	if max_bumps > 0:
		update_bump_counter()
		if bumps >= max_bumps:
			on_final_bump()

func on_final_bump():
	bump_limit_reached = true
	activate_bump()
	#should do explosion here for final bump
	await extend_end
	if point_yield_after_destruction > 0:
		gm.gain_points(point_yield_after_destruction)
		gm.on_loot_scored.emit(global_position, point_yield_after_destruction) #on_loot_scored() used for scorekeeper to spawn point notifs around the score location
	queue_free()

func update_bump_counter():
	bump_counter.text = str(bumps)


func activate_bump(body : Node2D = null):
	#print("bumping")
	if body == null: #the only time this is null is when it dies, this is a forced extend
		extend_time_timer = extend_time
		extended = true
		bump()
		return

	just_bumped.emit()
	if body.has_meta("main_wall"):
		bump_self()
		return
	if not (body as Loot):
		return

	if loot_in_range.size() == 0:
		return

	if not extended:
		extended = true
		bump()
		extend_time_timer = extend_time

func bump_self():
	var push_dir : Vector2 = (Vector2.ZERO - global_position).normalized()
	apply_central_impulse(push_dir * impulse_amount)

func bump():
	#print("bump")
	for i in loot_in_range:
		if is_instance_valid(i):
			var push_dir : Vector2 = (i.global_position - global_position).normalized()
			i.apply_central_impulse(push_dir * impulse_amount)
			apply_central_impulse(-push_dir * impulse_amount)
		


func _on_body_entered(body : Node2D):
	#print("body entered")
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
