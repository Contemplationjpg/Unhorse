class_name UnstableLoot
extends Loot

@export var explosion_effect : GPUParticles2D 

var exploding = false

func _ready() -> void:
	super()
	just_landed.connect(landing_explosion)
	just_bounced.connect(bouncing_explosion)


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
