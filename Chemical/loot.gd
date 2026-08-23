class_name Loot
extends RigidBody2D

@export_category("Debug")
@export var print_linear_velocity : bool = false
@export var score_on_debug_button : bool = false

@export_category("Stats")
@export var base_point_value : int = 10
@export var spawn_rate : int = 1


@export_group("Bounce Variation")
@export var do_bounce_variation : bool = true
@export var bounce_variation_strength : float = 0.1


@export_group("Bounce Bonus")
##if this is false, this still experiences collisions but none of the bounce tracking code will work
@export var track_bounces : bool = true
##the flat amount that will be added to the bounce bonus. bounce bonus is a multiplier applied at time of scoring. i.e. 10 base score * ( 1 bounce bonus + 0.5 increase * 4 bounces) = 10 * 3 = 30 points
@export var bounce_bonus_increase_per_bounce : float = 0.5
##if the loot's linear velocity ever hits this value, reset bounce count and bounce bonus. set to a negative number if you never want it to reset
@export var bounce_bonus_reset_minimum_velocity : float = 0 
##color filter increases in saturation every time it bounces. also need to set bounces_until_max_color for this to work 
@export var becomes_more_saturated_per_bounce : bool = true
##this will determine how many bounces until sprite is at max saturation. i.e. bounces_until_max_color = 10: on 9th bounce 9/10 saturation, on 10th bounce 10/10 saturation, on 11th bounce 10/10 saturation. requires becomes_more_saturated_per_bounce to be true
@export var bounces_until_max_color : int = 10
##the amount of bounces until bounce bonus no longer increases
@export var bounces_until_max_bounce_bonus : int = 10


@export_subgroup("Bounce Speed Up")
##every bounce increases linear velocity. always adds flat_bounce_speed_up and then multiplies by mult_bounce_speed_up. optionally multiplies by bounce bonus value at end of calculation.
@export var speeds_up_with_bounces : bool = false
##adds a flat value to the linear velocity (gets normallized direction then multiplies by flat value then adds that new vector to the linear velocity). happens before multiplying mult value. requires speeds_up_with_bounces to be true.
@export var flat_bounce_speed_up : float = 0
##multiplies linear velocity by this value. happens after adding flat value. requires speeds_up_with_bounces to be true.
@export var mult_bounce_speed_up : float = 1
##will multiply linear velocity by the current bounce bonus value AFTER the other flat and mult speed ups are applied. requires speeds_up_with_bounces to be true.
@export var bounce_speed_up_uses_bounce_bonus : bool = false


@export_subgroup("Speed Cap")
##if this is true, the linear velocity cannot go past the cap specified by speed_cap
@export var has_speed_cap : bool = false
##requires has_speed_cap to be on.
@export var speed_cap : float = 600


@export_subgroup("Bounce Limit")
@export var has_bounce_limit : bool = false
##bounce limit trigger happens at this many bounces
@export var bounce_limit : int = 15
##deletes upon contact, final thing that happens (i.e. scores, explodes, then deletes)
@export var deletes_on_bounce_limit : bool = false
##does not delete if you have this toggled
@export var explodes_on_bounce_limit : bool = false
##each bounce scores its total score (kinda crazy if doesn't delete)
@export var scores_on_bounce_limit : bool = false

@export_group("")
##if true, can be picked up by claw
@export var grabbable : bool = true
@export var do_impulse_on_landing = true
##the strength that this loot will impulse other loot objects if this lands on them after being dropped from the claw
@export var impulse_amount : float = 30

@export var min_scale : float = 0.5
@export var max_scale : float = 1

@export var maximum_speed_before_unscorable : float = 1500

var rise_time : float = 1
@export var drop_time : float = 1

@export_group("Scoring Visuals")
@export var time_to_score : float = 2
@export var color_value_lower_speed : float = 0.5



signal just_bounced()
signal just_scored()

signal just_landed()



var color_value_lower_amount_per_sec : float = time_to_score/color_value_lower_speed

var drop_time_modifier : float = 1
var impulse_modifier : float = 1
var velocity_modifier : float = 1
var point_value_modifier : float = 1

var hole_point_modifier : float = 1

#upgrade modifiers-----------------

var value_upgrade : int = 0

var speed_upgrade : int = 0

var bonus_upgrade : int = 0



var value_upgrade_amount : int = 0

var speed_upgrade_amount : int = 0
var speed_cap_raise_amount : int = 0

var bonus_upgrade_amount : int = 0

#----------------------------------------------

var rise_scale_change_per_sec : float = (max_scale - min_scale)/rise_time
var drop_scale_change_per_sec : float = (max_scale - min_scale)/drop_time*drop_time_modifier

@onready var sprite : Sprite2D = $Sprite2D 
@onready var coll : CollisionShape2D = $CollisionShape2D #this is physical collision
@onready var area : Area2D = $Area2D #this is are for detection around where the loot would land, area should match size of coll unless a special effect is intended
@onready var gm : ChemicalGameManager = ChemicalGameManager




var claw : Claw

#states
var picked_up : bool = false #true on claw_begin_rise if this loot is grabbed
var can_score : bool = true #true as long as linear velocity is below a certain amount

var scoring : bool = false #true once falling into a hole (or forced by other means)

var bounce_bonus : float = 1
var bounces : int = 0

var nearby_loot_on_drop : Array[Loot] = [] #container for other loot that is nearby when we drop so that we know which loot to impulse
var nearby_bumpers_on_drop : Array[Bumper] = [] #container for other bumpers that is nearby when we drop so that we know which bumpers to impulse


func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exit)
	area.area_entered.connect(_on_area_entered)
	area.area_exited.connect(_on_area_exit)
	body_entered.connect(on_bounce)
	gm.update_upgrades.connect(update_upgrades)
	gm.clear_all_loot.connect(on_clear_all_loot)
	update_upgrades()
	


func _physics_process(delta: float) -> void:
	#apply speed cap------------------------------------------
	if has_speed_cap:
		if linear_velocity.length() > speed_cap:
			linear_velocity = linear_velocity.normalized()*speed_cap

	#checking if scorable----------------------------------
	if linear_velocity.length() < maximum_speed_before_unscorable:
		can_score = true
	else:
		can_score = false
	
	#reset bounce bonus if going too slow	
	if linear_velocity.length() < bounce_bonus_reset_minimum_velocity:
		reset_bounces()	

	#debug------------------------------------------------
	if print_linear_velocity:
		#print(str(linear_velocity.length()))
		#print(sprite.self_modulate.s)
		#print(str(bounce_bonus))
		print(nearby_bumpers_on_drop)
	
	if score_on_debug_button:
		if Input.is_action_just_pressed("debug"):
			start_score()


func _process(delta: float) -> void:
	#self_modulate color based on how much bounce bonus
	if becomes_more_saturated_per_bounce:
		sprite.self_modulate.s = ((bounce_bonus-1)/10)
	else:
		sprite.self_modulate.s = 0

	#procedure for being picked up into the air
	if picked_up:
		coll.set_deferred("disabled", true)
		sprite.z_index = 7 #should be on a higher z_index than items on the ground (z_index 1) and outer wall (z_index 6)
		linear_velocity = Vector2.ZERO
		global_position = lerp(global_position, claw.global_position,0.5*delta)
		if sprite.scale < Vector2(max_scale, max_scale):
			sprite.scale += Vector2(rise_scale_change_per_sec * delta, rise_scale_change_per_sec * delta)
		elif sprite.scale > Vector2(max_scale, max_scale):
			sprite.scale = Vector2(max_scale, max_scale) #failsafe for if it lags and we go past the max size
	
	#procedure for falling (collision is disabled when in the air, so the following only applies until touching the ground)
	elif coll.disabled == true:
		if sprite.scale > Vector2(min_scale, min_scale):
			sprite.scale -= Vector2(drop_scale_change_per_sec * delta, drop_scale_change_per_sec * delta)	
		elif sprite.scale < Vector2(min_scale, min_scale):
			sprite.scale = Vector2(min_scale, min_scale) #failsafe for if it lags and we go past the min size
		else: #once we are exactly the minimum size, we can assume that we have touched the ground
			just_landed.emit()
			sprite.z_index = 1 #z_index 1 is ground level
			#coll.disabled = false #since we touched ground, we can interact with other loot now
			coll.set_deferred("disabled", false)
			if not scoring:
				increment_bounce_bonus()
			if do_impulse_on_landing:
				push_away_nearby() #when touching the ground, apply impulse to other loot that we landed on
	
	#procedure for darkening sprite color value until fully dark
	elif scoring:
		if sprite.self_modulate.v > 0.01: #0.01 used because of risk of floating point error
			sprite.self_modulate.v -= color_value_lower_amount_per_sec * delta
		else:
			on_score()




#for scoring--------------------------------------------------------

func start_score() -> bool: #acts as a check for if this loot can be scored, returns true if can, false if cannot
	if not can_score or picked_up:
		return false
	scoring = true #becomes scoring state
	coll.disabled = true #cannot collide with others during this state
	linear_velocity = linear_velocity/2  #also half its velocity
	#angular_velocity = 0 #we can cut the spinning but it probably doesn't matter
	return true

func hole_start_score(hole_mult : float) -> bool: #same as start_score() except asks for hole multiplier
	if not can_score or picked_up:
		return false
	hole_point_modifier = hole_mult #set hole_multiplier
	scoring = true #becomes scoring state
	coll.disabled = true #cannot collide with others during this state
	linear_velocity = linear_velocity/2  #also half its velocity
	#angular_velocity = 0 #we can cut the spinning but it probably doesn't matter
	return true

func on_score(): #scores, then destroys self (made before the non-destroy version)
	on_score_non_destroy()
	queue_free() #gets destroyed

func on_score_non_destroy(): #scores without destroying self
	
	var score : int = int((base_point_value * pow(2, value_upgrade_amount)) * (bounce_bonus) * point_value_modifier * hole_point_modifier) #score rounded down to nearest int
	gm.gain_points(score)
	just_scored.emit()
	gm.on_loot_scored.emit(global_position, score) #on_loot_scored() used for scorekeeper to spawn point notifs around the score location

func increment_bounce_bonus():	
	if bounces_until_max_bounce_bonus >= 0 and bounce_bonus_increase_per_bounce > 0:
		if bounces < bounces_until_max_bounce_bonus:
			bounce_bonus += bounce_bonus_increase_per_bounce * pow(2, bonus_upgrade_amount)
			gm.on_loot_bonus_update.emit(global_position, bounce_bonus)

func on_bounce(_body : Node2D):

	#add variation on bounce so its less likely for loot to get stuck bouncing indefinitely
	if do_bounce_variation:
		var rng = randi_range(0,1)#randomly pick if bounce influence should go to left or right
		var bounce_variation : Vector2
		if rng == 1:
			bounce_variation = Vector2(-linear_velocity.y, linear_velocity.x)*bounce_variation_strength #right variation
		else:
			bounce_variation = Vector2(linear_velocity.y, -linear_velocity.x)*bounce_variation_strength #left variation
		apply_central_impulse(bounce_variation)
	

	if not track_bounces:
		return
	just_bounced.emit()
	increment_bounce_bonus()
	if speeds_up_with_bounces:
		#make copy of linear_velocity to edit
		var new_linear_velocity = linear_velocity
		#creating flat vector from flat value
		var flat_vector = Vector2(linear_velocity.x, linear_velocity.y)
		flat_vector = flat_vector.normalized()*(flat_bounce_speed_up+speed_upgrade_amount)
		new_linear_velocity+=flat_vector
		#multiply mult value
		new_linear_velocity*=mult_bounce_speed_up
		#optional use of bounce bonus
		if bounce_speed_up_uses_bounce_bonus:
			new_linear_velocity*=bounce_bonus
		#check if there is a speed cap
		if has_speed_cap:
			if new_linear_velocity.length() > (speed_cap+speed_cap_raise_amount):
				#max velocity is direction * speedcap
				new_linear_velocity = new_linear_velocity.normalized()*(speed_cap + speed_cap_raise_amount)
		linear_velocity = new_linear_velocity
	if has_bounce_limit:
		if bounces >= bounce_limit:
			if scores_on_bounce_limit:
				on_score_non_destroy()
			if explodes_on_bounce_limit:
				print("explosion (program explosions later)") #will program in the explosion later
			if deletes_on_bounce_limit:
				queue_free()
			#if you have bounce limit on but no settings, loot stops in place and resets bounces
			if not scores_on_bounce_limit and not explodes_on_bounce_limit and not deletes_on_bounce_limit: 
				linear_velocity = Vector2.ZERO
				angular_velocity = 0
				reset_bounces()
	bounces+=1

func reset_bounces():	
	bounce_bonus = 1
	bounces = 0

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


func _on_area_entered(body : Node2D):
	var bumper = body.get_parent() as Bumper
	if bumper:
		if nearby_bumpers_on_drop.find(bumper) == -1: #find() returns -1 if nothing found
			nearby_bumpers_on_drop.append(bumper)


func _on_area_exit(body : Node2D):
	var bumper = body.get_parent() as Bumper
	if bumper:
		if not nearby_bumpers_on_drop.find(bumper) == -1: #find() returns -1 if nothing found
			nearby_bumpers_on_drop.erase(bumper)

func push_away_nearby():
	for i in nearby_loot_on_drop:
		var push_dir : Vector2 = (i.global_position - global_position).normalized()
		i.apply_central_impulse(push_dir * impulse_amount * impulse_modifier)
		apply_central_impulse(-push_dir*impulse_amount*impulse_modifier) #applies half of impulse on self but this will probably be changed to be full impulse
	for i in nearby_bumpers_on_drop:
		var push_dir : Vector2 = (i.global_position - global_position).normalized()
		i.apply_central_impulse(push_dir * impulse_amount * impulse_modifier)
		apply_central_impulse(-push_dir*impulse_amount*impulse_modifier) #applies half of impulse on self but this will probably be changed to be full impulse
		i.activate_bump()
		i.just_bumped.emit()
	impulse_modifier = 1


#for use by a claw---------------------------------------

func get_grabbed(c : Claw) -> bool:
	if scoring or not grabbable:
		return false
	claw = c
	rise_time = claw.rise_time
	drop_time_modifier = claw.loot_drop_time_modifier
	impulse_modifier = claw.loot_impulse_modifier
	velocity_modifier = claw.loot_velocity_modifier
	point_value_modifier = claw.loot_point_value_modifier

	rise_scale_change_per_sec = (max_scale - min_scale)/rise_time
	drop_scale_change_per_sec = (max_scale - min_scale)/drop_time*drop_time_modifier

	claw.claw_start_rise.connect(get_picked_up) #connects signal for claw to start rising to our picked_up state
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	return true

func force_to_be_held(c : Claw):
	claw = c
	picked_up = true
	coll.set_deferred("disabled", true)
	sprite.z_index = 7 #should be on a higher z_index than items on the ground (z_index 1) and outer wall (z_index 6)
	linear_velocity = Vector2.ZERO
	global_position = c.global_position
	sprite.scale = Vector2(max_scale, max_scale) #force to be max size	

func force_to_be_in_air():
	await get_tree().create_timer(0.02).timeout
	coll.set_deferred("disabled", true)
	sprite.z_index = 7 #should be on a higher z_index than items on the ground (z_index 1) and outer wall (z_index 6)
	linear_velocity = Vector2.ZERO
	sprite.scale = Vector2(max_scale, max_scale) #force to be max size	
	picked_up = false


func get_picked_up():
	picked_up = true
	claw.claw_start_rise.disconnect(get_picked_up) #immediately after getting the signal for being picked up, we can disconnect the signal since we can only assume we are getting picked up once

func get_dropped(c : Claw):
	picked_up = false
	linear_velocity = c.velocity*velocity_modifier #applies claw velocity * velocity_modifier to the loot linear velocity
	velocity_modifier = 1


#stats--------------------------------------------------------------------------

func update_upgrades():	
	value_upgrade = gm.loot_value_upgrade
	match value_upgrade:
		0:
			value_upgrade_amount = 0
		1:
			value_upgrade_amount = 1
		2:
			value_upgrade_amount = 2
		_:
			value_upgrade_amount = 3

	speed_upgrade = gm.loot_speed_upgrade
	match speed_upgrade:
		0:
			speed_cap_raise_amount = 0
			speed_upgrade_amount = 0
		1:
			speed_cap_raise_amount = 200
			speed_upgrade_amount = 100
		2:
			speed_cap_raise_amount = 500
			speed_upgrade_amount = 200
		_:
			speed_cap_raise_amount = 800
			speed_upgrade_amount = 250

	bonus_upgrade = gm.loot_bonus_upgrade
	match bonus_upgrade:
		0:
			bonus_upgrade_amount = 0
		1:
			bonus_upgrade_amount = 1
		2:
			bonus_upgrade_amount = 2
		_:
			bonus_upgrade_amount = 3


#misc---------------------------------------------------------------------------

func reset_all_modifiers():
	drop_time_modifier = 1
	impulse_modifier = 1
	velocity_modifier = 1
	point_value_modifier = 1
	
func on_clear_all_loot():
	if not picked_up:
		queue_free()
