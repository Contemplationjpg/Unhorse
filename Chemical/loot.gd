class_name Loot
extends RigidBody2D

@export_category("Debug")
@export var print_linear_velocity : bool = false

@export_category("Stats")
@export var impulse_amount : float = 30

@export var min_scale : float = 0.5
@export var max_scale : float = 1

@export var maximum_speed_before_unscorable : float = 1500

var rise_time : float = 1
var drop_time : float = 1

var rise_scale_change_per_sec : float = (max_scale - min_scale)/rise_time
var drop_scale_change_per_sec : float = (max_scale - min_scale)/drop_time

@onready var sprite : Sprite2D = $Sprite2D 
@onready var coll : CollisionShape2D = $CollisionShape2D #this is physical collision
@onready var area : Area2D = $Area2D #this is are for detection around where the loot would land, area should match size of coll unless a special effect is intended




var claw : Claw

#states
var picked_up : bool = false #true on claw_begin_rise if this loot is grabbed
var can_score : bool = true #true as long as linear velocity is below a certain amount

var nearby_loot_on_drop : Array[Loot] = [] #container for other loot that is nearby when we drop so that we know which loot to impulse


func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exit)


func _physics_process(delta: float) -> void:
	#checking if scorable----------------------------------
	if linear_velocity.length() < maximum_speed_before_unscorable:
		can_score = true
	else:
		can_score = false
	
	#debug------------------------------------------------
	if print_linear_velocity:
		print(str(linear_velocity.length()))


func _process(delta: float) -> void:
	#procedure for being picked up into the air
	if picked_up:
		coll.disabled = true
		linear_velocity = Vector2.ZERO
		if sprite.scale < Vector2(max_scale, max_scale):
			sprite.scale += Vector2(rise_scale_change_per_sec * delta, rise_scale_change_per_sec * delta)
		elif sprite.scale > Vector2(max_scale, max_scale):
			sprite.scale = Vector2(max_scale, max_scale) #failsafe for if it lags and we go past the max size
	
	#procedure for falling (collision is disabled when in the air, so the following only applies until touching the ground)
	elif coll.disabled:
		if sprite.scale > Vector2(min_scale, min_scale):
			sprite.scale -= Vector2(drop_scale_change_per_sec * delta, drop_scale_change_per_sec * delta)	
		elif sprite.scale < Vector2(min_scale, min_scale):
			sprite.scale = Vector2(min_scale, min_scale) #failsafe for if it lags and we go past the min size
		else: #once we are exactly the minimum size, we can assume that we have touched the ground
			coll.disabled = false #since we touched ground, we can interact with other loot now
			push_away_nearby() #when touching the ground, apply impulse to other loot that we landed on



#for deciding which object to apply propulsion to when dropped----------------------------------
func _on_body_entered(body : Node2D):
	var other_loot = body as Loot
	if other_loot:
		if nearby_loot_on_drop.find(other_loot) == -1: #find() returns -1 if nothing found
			nearby_loot_on_drop.append(other_loot)

func _on_body_exit(body : Node2D):
	var other_loot = body as Loot
	if other_loot:
		if not nearby_loot_on_drop.find(other_loot) == -1:#find() returns -1 if nothing found
			nearby_loot_on_drop.erase(other_loot)

func push_away_nearby():
	for i in nearby_loot_on_drop:
		var push_dir : Vector2 = (i.global_position - global_position).normalized()
		i.apply_central_impulse(push_dir * impulse_amount)
		apply_central_impulse(-push_dir*impulse_amount/2) #applies half of impulse on self but this will probably be changed to be full impulse


#for use by a claw---------------------------------------
func get_grabbed(c : Claw):
	claw = c
	rise_time = claw.rise_time
	drop_time = claw.drop_time
	
	#we match the rise time and drop time, though drop time changing doesn't make too much sense to copy
		#probably instead of copying drop time, we can ask the claw for a drop time multiplier so if we made a cannon or something, it could just apply easily
	rise_scale_change_per_sec = (max_scale - min_scale)/rise_time
	drop_scale_change_per_sec = (max_scale - min_scale)/drop_time

	claw.claw_start_rise.connect(get_picked_up) #connects signal for claw to start rising to our picked_up state
	linear_velocity = Vector2.ZERO

func get_picked_up():
	picked_up = true
	claw.claw_start_rise.disconnect(get_picked_up) #immediately after getting the signal for being picked up, we can disconnect the signal since we can only assume we are getting picked up once

func get_dropped():
	picked_up = false
