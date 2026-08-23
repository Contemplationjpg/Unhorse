class_name HorseBomb
extends GPUParticles2D

@export var area : Area2D
@export var sound : AudioStreamPlayer

@export var do_knockback_on_detonate : bool = false
@export var destroy_after_detonate : bool = true
@export var impulse_amount : float = 500

var loot_in_range : Array[Loot] = []

var exploding : bool = false


var anim_finished : bool = false
var sound_finished : bool = false
signal okay_to_free

func _ready():
	emitting = false
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exit)

	finished.connect(on_anim_finished)
	sound.finished.connect(on_sound_finished)
	return

func on_anim_finished():
	anim_finished = true
	if anim_finished and sound_finished:
		okay_to_free.emit()

func on_sound_finished():
	sound_finished = true
	if anim_finished and sound_finished:
		okay_to_free.emit()

func play_sound():	
	var rng = randf_range(0.8,1.2)
	sound.pitch_scale = rng
	sound.playing = true

func explode():
	if not exploding:
		exploding = true
		bump()
		emitting = true
		play_sound()
		await okay_to_free
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
