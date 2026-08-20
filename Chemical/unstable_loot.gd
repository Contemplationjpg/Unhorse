class_name UnstableLoot
extends Loot

@export var explosion_effect : GPUParticles2D 

func _ready() -> void:
	super()
	just_landed.connect(play_explosion)
	just_bounced.connect(play_explosion)

func play_explosion():
	can_score = false
	sprite.visible = false
	set_deferred("freeze", true)
	push_away_nearby()
	explosion_effect.emitting = true
	await explosion_effect.finished
	queue_free()
