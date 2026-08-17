class_name Claw
extends CharacterBody2D

@export_category("Claw Stats")
@export var move_speed : float = 100

@export var drop_time : float = 0.25

##time after claw drops before it rises
@export var grab_pause : float = 1

@export var rise_time : float = 0.5

##cooldown between doing another grab. starts when claw finishes rising
@export var grab_cooldown : float = 1.5 

@export_subgroup("Opacity")
@export var max_opacity : float = 1
@export var min_opacity : float = 0.15

@export_subgroup("Scale")
@export var max_scale : float = 0.5
@export var min_scale : float = 0.25







@onready var sprite : Sprite2D = $Sprite2D
@onready var area : Area2D = $Area2D

#states
var grabbing : bool = false #true if doing the grab process at all, from claw_start_drop to claw_end_rise
var dropping : bool = false #true from claw_start_drop to claw_end_drop
var down : bool = false #true from claw_start_down to claw_end_down
var rising : bool = false #true from claw_start_rise to claw_end_rise

var holding : bool = false


#signals correlated to the states grabbing, dropping, down, rising
signal claw_start_drop()
signal claw_end_drop()

signal claw_start_down()
signal claw_end_down()

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
var grab_pause_timer : float = 0

var loot_in_range : Array[Loot] = []
var loot_held : Array[Loot] = []



func _ready() -> void:
	sprite.self_modulate.a = min_opacity
	sprite.scale = Vector2(max_scale,max_scale)
	
	#setting up signals------------------
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exit)



#use update_stats() if drop/rise speed is ever changed mid-game
func update_stats():
	drop_opacity_change_per_sec = (max_opacity - min_opacity)/drop_time
	rise_opacity_change_per_sec = (max_opacity - min_opacity)/rise_time

	drop_opacity_change_per_sec = (max_opacity - min_opacity)/drop_time
	rise_opacity_change_per_sec = (max_opacity - min_opacity)/rise_time
	



func move():
	#claw movement------------------------------------------
	if not grabbing: #checks if you are grabbing or not
		var move_dir = Input.get_vector("left", "right","up","down")
		velocity = move_dir * move_speed

	move_and_slide() #include this after anything that changes velocity or involves collision






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



func drop():
	print("dropping")
	while (loot_held.size() > 0):
		loot_held[-1].reparent(get_parent())
		loot_held[-1].get_dropped()
		loot_held.remove_at(-1)
	holding = false



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
	
	if loot_held.size() > 0:
		holding = true
	


func claw_physics_process(delta : float):
	#check for grab input------------------------------------------------
	if Input.is_action_just_pressed("drop") and not grabbing:
		if holding:
			drop()
		else:
			#print("grabbing")
			if grab_cooldown_timer <= 0:#checks if grabbing on cooldown
				velocity = Vector2.ZERO
				grab()
	
	#process movement-------------------------------------------
	move()

	if down:
		pick_up_loot()


func pick_up_loot():
	if loot_in_range.size() > 0:
		for i in loot_in_range:
			i.global_position = global_position
			i.get_grabbed(self)
			i.reparent(self)
			loot_held.append(i)
			loot_in_range.erase(i)



func _on_body_entered(body : Node2D):
	var new_loot = body as Loot
	if not new_loot:
		return
	if loot_in_range.find(new_loot) == -1:
		loot_in_range.append(new_loot)
		print("hello")
	else:
		print("what da sigma")

func _on_body_exit(body : Node2D):
	var exit_loot = body as Loot
	var loot_index = loot_in_range.find(exit_loot)
	if loot_index != -1:
		print("removing body")
		loot_in_range.remove_at(loot_index)
