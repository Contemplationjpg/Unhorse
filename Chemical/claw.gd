class_name Claw
extends CharacterBody2D

@export_group("Claw Stats")
@export var move_speed : float = 100
##cooldown between doing another grab. starts when claw finishes rising
@export var grab_cooldown : float = 1.5 
##time after claw drops before it rises
@export var grab_pause : float = 1

@export_subgroup("Opacity")
@export var rise_time : float = 0.5
@export var drop_time : float = 0.25
@export var max_opacity : float = 1
@export var min_opacity : float = 0.15

@export_subgroup("Scale")
@export var max_scale : float = 0.5
@export var min_scale : float = 0.25







@onready var sprite = $Sprite2D


#states
var grabbing = false #if doing the grab process at all, this is true from claw_start_drop to claw_end_rise
var dropping = false #true from claw_start_drop to claw_end_drop
var down = false #true from claw_start_down to claw_end_down
var rising = false #true from claw_start_rise to claw_end_rise


#signals correlated to the states grabbing, dropping, down, rising
signal claw_start_drop()
signal claw_end_drop()

signal claw_start_down()
signal claw_end_down()

signal claw_start_rise()
signal claw_end_rise()

signal claw_grab()


#timing for visual changes, also calculated in update_stats()
var drop_scale_change_per_sec = (max_scale - min_scale)/drop_time
var rise_scale_change_per_sec = (max_scale - min_scale)/rise_time

var drop_opacity_change_per_sec = (max_opacity - min_opacity)/drop_time
var rise_opacity_change_per_sec = (max_opacity - min_opacity)/rise_time


#timers for grab logic
var grab_cooldown_timer = 0
var grab_pause_timer = 0


func _ready() -> void:
	sprite.self_modulate.a = min_opacity
	sprite.scale = Vector2(max_scale,max_scale)

#use update_stats() if drop/rise speed is ever changed mid-game
func update_stats():
	drop_opacity_change_per_sec = (max_opacity - min_opacity)/drop_time
	rise_opacity_change_per_sec = (max_opacity - min_opacity)/rise_time

	drop_opacity_change_per_sec = (max_opacity - min_opacity)/drop_time
	rise_opacity_change_per_sec = (max_opacity - min_opacity)/rise_time
	



func move():
	#claw movement------------------------------------------
	if not grabbing:
		var move_dir = Input.get_vector("left", "right","up","down")
		velocity = move_dir * move_speed
	move_and_slide()






func grab():
	grabbing = true #starting grab
	
	#claw drop---------------------
	claw_start_drop.emit()
	dropping = true
	await claw_end_drop
	dropping = false

		#claw down------------------
	down = true
	claw_start_down.emit()

	claw_grab.emit()#this is where claw should grab stuff 

	grab_pause_timer = grab_pause #starts grab pause
	await claw_end_down #waits for grab pause timer to be up
	down = false

	#claw rise--------------------
	claw_start_rise.emit()
	rising = true
	await claw_end_rise
	rising = false
	
	grabbing = false #end of grab process
	grab_cooldown_timer = grab_cooldown #starts grab cooldown





func claw_process(delta : float): #fix claw scale
	
	#update timers--------------------------
	if grab_cooldown_timer > 0:
		grab_cooldown_timer -= delta
	if grab_pause_timer > 0:
		grab_pause_timer -= delta

	#grab visual processing based on state of claw (grabbing, dropping, down, rising)----------------------------
	if grabbing:
		if dropping:
			if sprite.self_modulate.a < max_opacity:
				sprite.self_modulate.a += drop_opacity_change_per_sec*delta
				sprite.scale -= Vector2(drop_scale_change_per_sec*delta,drop_scale_change_per_sec*delta)
			else:
				claw_end_drop.emit()
		elif down:
			if grab_pause_timer <= 0:
				claw_end_down.emit()
		elif rising:
			if sprite.self_modulate.a > min_opacity:
				sprite.self_modulate.a -= rise_opacity_change_per_sec*delta
				sprite.scale += Vector2(rise_scale_change_per_sec*delta,rise_scale_change_per_sec*delta)
			else:
				#print("ending claw rise")
				claw_end_rise.emit()






func claw_physics_process(delta : float):
	#check for grab input------------------------------------------------
	if Input.is_action_just_pressed("drop") and not grabbing: #checks if grabbing
		#print("grabbing")
		if grab_cooldown_timer <= 0:#checks if grabbing on cooldown
			velocity = Vector2.ZERO
			grab()
		#else:
			#print("cannot grab! grab cooldown at " + str(grab_cooldown_timer))

	#process movement-------------------------------------------
	move()
