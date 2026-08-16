class_name BasicClaw
extends Claw

#states:
#grabbing - true if doing the grab process at all, from claw_start_drop to claw_end_rise
#dropping - true from claw_start_drop to claw_end_drop
#down - true from claw_start_down to claw_end_down
#rising - true from claw_start_rise to claw_end_rise

#default checks if grabbing, then if not grabbing gets a Vector2 (move_dir) from movement inputs, then sets the velocity = move_dir * move_speed 
#ends in move_and_slide()
func move():
	super()

#default emits start signals for when each state starts and starts timers
func grab(): 
	super()

#default includes visual updates to opacity & scale to match the current state, and emits end signals for when each state ends after visually fully changed to match (opacity & scale)
#also updates timers and checks timers before sending end signals for each state
func claw_process(delta : float): 
	super(delta)

#default includes input reading for grabbing (grab()) and movement (move())
func claw_physics_process(delta : float): 
	super(delta)

