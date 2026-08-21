extends Control

@export_group("Wheel Setup")
@export var wheel : Control
@export var arrow : Area2D
@export var auto_spin_toggle : Button
@export_group("Spin Settings")
@export var spin_clockwise : bool = true
@export var max_spin_velocity : float = 100 #degrees of rotation per second
@export var spin_acceleration : float = 10
@export var spin_deceleration : float = 5
##if set to zero or a negative, can stop at any time
@export var time_before_stoppable : float = 1.5
@export var stop_buffer_window : float = 1
##if set to zero or a negative, will never auto stop
@export var time_before_auto_stop : float = 4

signal on_start_spin()
signal on_stop_spin()
signal on_full_stop_spin()


#states
var spinning : bool = false
var stopping_spin : bool = false
var stop_input_buffered : bool = false

#dealing with the spin
var current_spin_velocity : float = 0
var time_before_stoppable_timer : float = 0
var time_before_auto_stop_timer : float = 0
var auto_spin : bool = false

#dealing with rewards
var last_color : int = 0




@onready var gm : ChemicalGameManager = ChemicalGameManager

func _ready() -> void:
	arrow.area_entered.connect(on_enter_area)
	auto_spin_toggle.toggled.connect(on_auto_spin_toggle)

func on_auto_spin_toggle(toggle : bool):
	auto_spin = toggle

#scoring------------------------------------------------------------------

#each section of the wheel has an area with the metadata "color" 
#Color is int where 0 = blue, 1 = red, 2 = yellow
func on_enter_area(body : Node2D): 
	if body.has_meta("color"):
		last_color = body.get_meta("color")
#print(str("last color: " + str(last_color)))

func spin_end_rewards():
	match last_color:
		0:
			#print("wheel ended on blue")
			gm.gain_plays(3)
		1:
			#print("wheel ended on red")
			gm.gain_points(300)
		2:
			#print("wheel ended on yellow")
			gm.gain_points(1000)


#process spinning --------------------------------------------------------------
func _process(delta: float) -> void:
	if time_before_stoppable_timer > 0:
		time_before_stoppable_timer -= delta
	if time_before_auto_stop_timer > 0:
		time_before_auto_stop_timer -= delta


func _physics_process(delta: float) -> void:
<<<<<<< Updated upstream
	if Input.is_action_just_pressed("debug"):
=======
	if Input.is_action_just_pressed("spin") or auto_spin:
>>>>>>> Stashed changes
		handle_spin_input()

	#spinning------------------------------------
	if spinning:
		
		#logic for deciding if the spin should begin stopping process----------------------
		if not stopping_spin:
			if time_before_auto_stop > 0 and time_before_auto_stop_timer <= 0:
				#print("autostopping wheel")
				stop_wheel()
			if stop_input_buffered:
				if time_before_stoppable_timer <= 0:
					stop_wheel()
					stop_input_buffered = false
				else:
					pass#print("stop input buffered but still on cooldown")
		
		#calculating the spin velocity of the wheel using spin acceleration-----------------------
		if not stopping_spin:
			if current_spin_velocity < max_spin_velocity: 
				current_spin_velocity += spin_acceleration * delta
			else:
				current_spin_velocity = max_spin_velocity
		else:	
			if current_spin_velocity > 0: 
				current_spin_velocity -= spin_deceleration * delta
			else:
				current_spin_velocity = 0 

		#doing the spin motion based on spin velocity------------------------
		var new_rot 
		if spin_clockwise:
			new_rot = wheel.rotation_degrees + current_spin_velocity
			#new_rot %= 360 #only had this to make sure the number doesn't get too big but it doesn't matter since rotation_degrees already does this and the value loops if somehow passes float maximum
			wheel.rotation_degrees = new_rot
		else:
			new_rot = wheel.rotation_degrees - current_spin_velocity
			#new_rot %= 360 #this line is not necessary
			wheel.rotation_degrees = new_rot
		
		#counting the spin as "stopped" once the wheel's spin velocity is 0------------------------
		if current_spin_velocity <= 0: 
			post_spin_procedure()



func post_spin_procedure():
	force_stop_wheel()
	spin_end_rewards()


#if there is a shared input for both starting and stopping the wheel, use this function
func handle_spin_input():
	if not spinning:
		if not gm.spend_spins(1):
			return
		spin_wheel()
	else:
		buffer_stop_spin_input()


#buffer_stop_spin_input() lets you buffer (store input to go through on the first actionable frame) a stop input
		#in _physics_process(), if:
			#spinning == true
			#time_before_stoppable_timer <= 0
			#stop_input_buffered == true
		#then tells the wheel to begin stop process
func buffer_stop_spin_input(): 
	if not stop_input_buffered: 
		if time_before_stoppable > 0: #if time_before_stoppable is a positive non-zero number, check the timer
			if time_before_stoppable_timer <= stop_buffer_window: #only buffers input if close enough to the time
				stop_input_buffered = true
				#print("stop input buffered")
			else: #if no cooldown to stop, just buffers the stop input
				stop_input_buffered = true



func spin_wheel() -> bool: #starts spinning the wheel and starts associated timers
	if spinning:
		return false
	#print("starting wheel")
	if time_before_stoppable > 0:
		time_before_stoppable_timer = time_before_stoppable
	if time_before_auto_stop > 0:
		time_before_auto_stop_timer = time_before_auto_stop
	stopping_spin = false
	spinning = true
	on_start_spin.emit()
	return true


func stop_wheel(): #begins to slow down the wheel
	#print("stopping wheel")
	stopping_spin = true
	on_stop_spin.emit()

func force_stop_wheel():#forces wheel to stop spinning
	#print("wheel fully stopped")
	spinning = false
	stop_input_buffered = false
	current_spin_velocity = 0
	on_full_stop_spin.emit()
