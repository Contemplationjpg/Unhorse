extends CharacterBody2D

@export var move_speed : float = 100
#@export var jump_strength : float = 500
@export var rise_speed : float = 5
@export var drop_speed : float = 5
@export var grab_cooldown : float = 1.5 #cooldown starts when claw finishes rising

@onready var sprite = $Sprite2D


signal claw_start_drop()
signal claw_end_drop()
signal claw_start_rise()
signal claw_end_rise()

signal claw_grab()


const MAX_OPACITY : float = 1
const MIN_OPACITY : float = 0.3


var grabbing = false
var dropping = false
var rising = false

var grab_cooldown_timer = 0


func _ready() -> void:
	sprite.self_modulate.a = MIN_OPACITY



func _physics_process(delta: float) -> void:
	
	'''
	#platformer movement (test code)------------------------------
	#get move direction (only left or right)
	var move_dir = Input.get_axis("left", "right") 
		#move_dir = -1 if left, = +1 if right, = 0 if both
	velocity = Vector2(move_speed * move_dir, velocity.y) 
	
	#handle jump
	if Input.is_action_just_pressed("jump"):
		velocity = Vector2(velocity.x, -jump_strength)
	else:
		#apply gravity
		velocity += get_gravity() * delta
	'''
	
	#claw movement------------------------------------------
	if Input.is_action_just_pressed("drop") and not grabbing: #checks if grabbing
		#print("grabbing")
		if grab_cooldown_timer <= 0:#checks if grabbing on cooldown
			velocity = Vector2.ZERO
			grab()
		else:
			print("cannot grab! grab cooldown at " + str(grab_cooldown_timer))

	if not grabbing:
		var move_dir = Input.get_vector("left", "right","up","down")
		velocity = move_dir * move_speed
	

	move_and_slide()


func _process(delta: float) -> void:
	if grab_cooldown_timer > 0:
		grab_cooldown_timer -= delta
	if grabbing:
		if dropping:
			if sprite.self_modulate.a < MAX_OPACITY:
				sprite.self_modulate.a += drop_speed*delta
				sprite.scale -= Vector2(drop_speed/3*delta,drop_speed/3*delta) #claw scale based on drop speed but should be a specified size that matches consistently sized collision box
			else:
				#print("ending claw drop")
				claw_end_drop.emit()
		elif rising:
			if sprite.self_modulate.a > MIN_OPACITY:
				sprite.self_modulate.a -= rise_speed*delta
				sprite.scale += Vector2(rise_speed/3*delta,rise_speed/3*delta)
			else:
				#print("ending claw rise")
				claw_end_rise.emit()

func grab():
	grab_cooldown_timer = grab_cooldown
	grabbing = true
	
	claw_start_drop.emit()
	dropping = true
	await claw_end_drop
	dropping = false
	
	claw_grab.emit()

	claw_start_rise.emit()
	rising = true
	await claw_end_rise
	rising = false
	
	grabbing = false
