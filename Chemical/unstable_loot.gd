class_name UnstableLoot
extends Loot

@export var explosion_effect : GPUParticles2D 

var exploding = false

func _ready() -> void:
	super()
	just_landed.connect(play_explosion)
	just_bounced.connect(play_explosion)

func play_explosion():
	if not exploding:
		exploding = true
		can_score = false
		sprite.visible = false
		push_away_nearby()
		set_deferred("freeze", true)
		explosion_effect.emitting = true
		await explosion_effect.finished
		queue_free()
