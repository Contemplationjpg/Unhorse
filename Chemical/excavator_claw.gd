class_name ExcavatorClaw
extends Claw

#states:
#grabbing - true if doing the grab process at all, from claw_start_drop to claw_end_rise
#dropping - true from claw_start_drop to claw_end_drop
#down - true from claw_start_down to claw_end_down, encompasses scooping and suspending
#scooping - true from claw_start_scoop to claw_end_scoop
#suspending - true from claw_start_suspension to claw_end_suspension
#rising - true from claw_start_rise to claw_end_rise

#holding - true if anything is in the loot_held array
	#drop() clears loot_held

#default checks if grabbing, then if not grabbing gets a Vector2 (move_dir) from movement inputs, then sets the velocity = move_dir * move_speed 
#ends in move_and_slide()

func move(): #overrides claw movement
	#claw movement------------------------------------------
	var move_dir = Input.get_vector("left", "right","up","down")
	velocity = move_dir * (move_speed)
	move_and_slide() #include this after anything that changes velocity or involves collision

#default checks if not already grabbing, if the grab_cooldown_timer is up, and if player has at least 1 play to spend
func pre_grab_requirement_check() -> bool:
	return super()

#default emits start signals for when each state starts and starts timers
	#also uses pre_drop_requirement_check() to see if it can grab
func grab(): 
	super()

#default checks if holding and not grabbing (meaning in the process of grabbing)
func pre_drop_requirement_check() -> bool:
	return super()

#default uses pre_drop_requirement_check() to see if it can drop
func drop():
	super()

#default includes visual updates to opacity & scale to match the current state, and emits end signals for when each state ends after visually fully changed to match (opacity & scale)
#also updates timers and checks timers before sending end signals for each state
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
				if scoop_time_timer <= 0 and not Input.is_action_pressed("drop"):
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
	



#default includes input reading for grabbing (grab()) and movement (move())
func claw_physics_process(delta : float): 
	super(delta)
