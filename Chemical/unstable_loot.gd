class_name UnstableLoot
extends Loot

@export var explosion_effect : GPUParticles2D 
@export var walks_around : bool = false
@export var walk_acceleration : float = 10
@export var walk_velocity : float = 20
@export var walk_range : float = 20


var exploding : bool = false
var walking : bool = false
var target_position : Vector2 = Vector2.ZERO

func _ready() -> void:
	super()
	just_landed.connect(landing_explosion)
	just_bounced.connect(bouncing_explosion)

func _physics_process(delta: float) -> void:
	super(delta)
	walk_around(delta)


func walk_around(delta : float):
	if not picked_up:
		if not walking:
			pick_target()
			walking = true
		else:
			var dir = global_position.direction_to(target_position)
			var vel = dir * walk_velocity
			linear_velocity = linear_velocity.lerp(vel, walk_acceleration * delta)
			if (global_position-target_position).length() < 5:
				pick_target()
	else:
		walking = false
		target_position = global_position

func pick_target():
	var rng = randi_range(-walk_range,walk_range)
	var x_range = rng
	rng = randi_range(-walk_range,walk_range)
	var y_range = rng
	target_position = Vector2(x_range, y_range)



func explode():
	if not exploding:
		exploding = true
		can_score = false
		sprite.visible = false
		push_away_nearby()
		set_deferred("freeze", true)
		explosion_effect.emitting = true
		await explosion_effect.finished
		queue_free()

func landing_explosion():
	explode()

func bouncing_explosion():
	if linear_velocity.length() < 50:
		return
	explode()
