class_name Claw
extends CharacterBody2D

@export_category("Claw Stats")
@export var move_speed : float = 100

@export var drop_time : float = 0.25

##time after claw drops before the actual scoop happens
@export var pre_scoop_pause : float = 0.25
##active time for the scoop, can be used to match an animation
@export var scoop_time : float = 0.25
##time after claw scoop before it rises
@export var grab_pause : float = 0.5

@export var rise_time : float = 0.5

##cooldown between doing another grab. starts when claw finishes rising
@export var grab_cooldown : float = 1.5 

@export_subgroup("Opacity")
@export var max_opacity : float = 1
@export var min_opacity : float = 0.15

@export_subgroup("Scale")
@export var max_scale : float = 0.5
@export var min_scale : float = 0.25

@export_category("Loot Modifiers")
@export var loot_drop_time_modifier : float = 1
@export var loot_impulse_modifier : float = 1
@export var loot_velocity_modifier : float = 1
@export var loot_point_value_modifier : float = 1


@export var sprite : AnimatedSprite2D 
@export var area : Area2D
@onready var gm : ChemicalGameManager = ChemicalGameManager


#states
var grabbing : bool = false #true if doing the grab process at all, from claw_start_drop to claw_end_rise
var dropping : bool = false #true from claw_start_drop to claw_end_drop
var down : bool = false #true from claw_start_down to claw_end_down
var scooping : bool = false #true from claw_start_scoop to claw_end_scoop
var suspending : bool = false #true from claw_start_suspension to claw_end_suspension
var rising : bool = false #true from claw_start_rise to claw_end_rise

var holding : bool = false


#signals correlated to the states grabbing, dropping, scooping, down, rising
signal claw_start_drop()
signal claw_end_drop()


signal claw_start_down()
signal claw_end_down()

signal claw_start_scoop()
signal claw_end_scoop()

signal claw_start_suspension()
signal claw_end_suspension()

signal claw_start_rise()
signal claw_end_rise()


#timing for visual changes, also calculated in update_stats()
var drop_scale_change_per_sec : float = (max_scale - min_scale)/drop_time
var rise_scale_change_per_sec : float = (max_scale - min_scale)/rise_time

var drop_opacity_change_per_sec : float = (max_opacity - min_opacity)/drop_time
var rise_opacity_change_per_sec : float = (max_opacity - min_opacity)/rise_time


#timers for grab logic
#timers tick down delta every frame, which means 1 unit per irl second, in claw_process()
var grab_cooldown_timer : float = 0
var pre_scoop_pause_timer : float = 0
var scoop_time_timer : float = 0
var grab_pause_timer : float = 0

var loot_in_range : Array[Loot] = []
var loot_held : Array[Loot] = []



func _ready() -> void:
	sprite.self_modulate.a = min_opacity
	sprite.scale = Vector2(max_scale,max_scale)
	sprite.animation = "idle"
	sprite.play("idle")
	update_stats()
	
	#setting up signals------------------
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exit)


func claw_process(delta : float): 
	
	#update timers--------------------------
	if grab_cooldown_timer > 0:
		grab_cooldown_timer -= delta
	if pre_scoop_pause_timer > 0:
		pre_scoop_pause_timer -= delta
	if scoop_time_timer > 0:
		scoop_time_timer -= delta
	if grab_pause_timer > 0:
		grab_pause_timer -= delta

	#grab visual processing based on state of claw (grabbing, dropping, down, scooping, suspension, rising)----------------------------
	if grabbing: #start of grab
		#this section is for the process of the claw dropping
		if dropping: 
			if sprite.self_modulate.a < max_opacity:
				sprite.self_modulate.a += drop_opacity_change_per_sec*delta
			else:
				#the 0.01 is safety precaution because setting a = min_opacity would sometimes end up with floating point number that is larger than the min_opacity so this is just for consistency with the rising end
				sprite.self_modulate.a = max_opacity + 0.01
			if sprite.scale > Vector2(min_scale, min_scale):
				sprite.scale -= Vector2(drop_scale_change_per_sec*delta,drop_scale_change_per_sec*delta)
			else:
				sprite.scale = Vector2(min_scale, min_scale)
				
			if sprite.self_modulate.a >= max_opacity and sprite.scale == Vector2(min_scale, min_scale):#this chunk happens when the claw has effectively touched the ground
				claw_end_drop.emit() 


		#this section is for the process of being down and scooping
				#there is are 3 pauses that can be tuned here: pre_scoop, scoop, grab_pause
		elif down:
			if not scooping and not suspending:#scoop hasn't happened yet
				if pre_scoop_pause_timer <= 0:
					claw_start_scoop.emit() #signal to activate scoop hitbox
			elif scooping: #scoop is now happening
				if scoop_time_timer <= 0:
					claw_end_scoop.emit() #signal to disable scoop hitbox
			
			elif suspending: #scoop has happened and now we are waiting for grab pause
				if grab_pause_timer <= 0:
					claw_end_suspension.emit() #grab pause has ended so we can end our "down" procedure and start rising
					claw_end_down.emit()
		#this section is for the process of rising, then starts cooldown
		elif rising:
			if sprite.self_modulate.a > min_opacity:
				sprite.self_modulate.a -= rise_opacity_change_per_sec*delta
			else:
				#the 0.01 is safety precaution because setting a = min_opacity would sometimes end up with floating point number that is larger than the min_opacity
				sprite.self_modulate.a = min_opacity-0.01
			if sprite.scale < Vector2(max_scale, max_scale):
				sprite.scale += Vector2(rise_scale_change_per_sec*delta,rise_scale_change_per_sec*delta)
			else:
				sprite.scale = Vector2(max_scale, max_scale)

			if sprite.self_modulate.a <= min_opacity and sprite.scale == Vector2(max_scale, max_scale):#this chunk happens when the claw has effectively reached the top
				#print("rose")
				claw_end_rise.emit() #tells that we made it back to the top
	

	if loot_held.size() > 0:
		holding = true
	


func claw_physics_process(delta : float):
	#check for grab input------------------------------------------------
	if Input.is_action_just_pressed("drop"):
		if holding:
			drop()
		else:
			#print("grabbing")
			grab()
	
	#process movement-------------------------------------------
	move()
	
	#pick up stuff if scoopbox should be active---------------------------
	if scooping:
		pick_up_loot()




#use update_stats() if drop/rise speed is ever changed mid-game
func update_stats():
	drop_opacity_change_per_sec = (max_opacity - min_opacity)/drop_time
	rise_opacity_change_per_sec = (max_opacity - min_opacity)/rise_time

	drop_opacity_change_per_sec = (max_opacity - min_opacity)/drop_time
	rise_opacity_change_per_sec = (max_opacity - min_opacity)/rise_time
	

#claw actions------------------------------------------------------
func move():
	#claw movement------------------------------------------
	if not grabbing:
		var move_dir = Input.get_vector("left", "right","up","down")
		velocity = move_dir * (move_speed)
	else:
		velocity = Vector2.ZERO
	move_and_slide() #include this after anything that changes velocity or involves collision



#used to check if able to grab
func pre_grab_requirement_check() -> bool:
	if grabbing: #checks if already grabbing
		return false
	if grab_cooldown_timer > 0:#checks if grabbing on cooldown
		return false
	if not gm.spend_plays(1): #tries to spend a play, returns false if cannot
		return false
	return true #only returns true after all checks are good



#does pre_grab_requirement_check() to see if able to grab
func grab():
	if not pre_grab_requirement_check(): #only does grab if all requirements are met
		return

	#begin the grab process--------------------------
	grabbing = true #starting grab

	#claw drop---------------------
	claw_start_drop.emit()
	dropping = true
	await claw_end_drop
	dropping = false

		#claw down----------------------------
	down = true
	claw_start_down.emit()
		#claw scoop---------------------------
	pre_scoop_pause_timer = pre_scoop_pause
	await claw_start_scoop
	claw_start_scoop.emit()
	scooping = true
	sprite.play("grab")#does grab animation for active grab box

	scoop_time_timer = scoop_time
	await claw_end_scoop
	scooping = false

	claw_start_suspension.emit()
	sprite.play("holding")#loops holding animation until claw rises to the top
	suspending = true
	grab_pause_timer = grab_pause #starts grab pause
	await claw_end_suspension #waits for grab pause timer to be up
	suspending = false
	
	await claw_end_down
	down = false

	#claw rise--------------------
	claw_start_rise.emit()
	rising = true
	await claw_end_rise
	rising = false
	
	if not holding:
		sprite.play("release_fail")#if not actually holding anything, do release animation then back to idle
		await sprite.animation_finished
		sprite.play("idle")
	grabbing = false #end of grab process
	grab_cooldown_timer = grab_cooldown #starts grab cooldown


func force_to_hold(new_loot : Loot)->bool:
	if grabbing:
		return false
	sprite.play("holding")
	holding = true
	new_loot.get_grabbed(self)
	new_loot.force_to_be_held(self)
	new_loot.global_position = global_position
	new_loot.reparent(self)
	loot_held.append(new_loot)
	return true




#used to check if able to drop
func pre_drop_requirement_check() -> bool:
	if not holding:
		return false
	if grabbing:
		return false
	return true


#does pre_grab_requirement_check() to see if able to drop
func drop():
	if not pre_drop_requirement_check():
		return
	#print("dropping")
	while (loot_held.size() > 0):
		if is_instance_valid(loot_held[-1]):
			loot_held[-1].reparent(get_parent())
			loot_held[-1].get_dropped(self)
		loot_held.remove_at(-1)
	sprite.play("release_success")
	await sprite.animation_finished
	sprite.play("idle")#after you drop everything, goes back to idle
	holding = false

#repeatedly called when scooping = true to pick up any loot that is within range of the scoopbox
func pick_up_loot():
	if loot_in_range.size() > 0: 
		for i in loot_in_range:
			if i.get_grabbed(self): #ask the loot to get grabbed
				i.global_position = global_position #lock the loot into our claw's position
				i.reparent(self) #parent the loot so that they follow the claw before they are dropped
				loot_held.append(i) #add loot to our list of currently held loot (used by drop() to know which loot to drop)
			loot_in_range.erase(i) #remove from loot_in_range because either we picked it up or we can't



#loot detection-------------------------------------------------------------------
	#detection box never turns off
func _on_body_entered(body : Node2D):
	var new_loot = body as Loot
	if not new_loot:
		return
	if loot_in_range.find(new_loot) == -1: #find() returns -1 if target not found
		loot_in_range.append(new_loot) #adds loot to list if it's not on the list yet
		#print("hello")
	#else:
		#print("what da sigma")

func _on_body_exit(body : Node2D):
	var exit_loot = body as Loot
	var loot_index = loot_in_range.find(exit_loot)
	if loot_index != -1: #find() returns -1 if target not found, so loot_index == -1 if not in our list somehow
		#print("removing body")
		loot_in_range.remove_at(loot_index) #uses loot index to know which loot to remove

#misc-------------------------------------
