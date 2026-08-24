class_name NewClaw
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
func move():
	super()

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
	super(delta)

#default includes input reading for grabbing (grab()) and movement (move())
func claw_physics_process(delta : float): 
	super(delta)
