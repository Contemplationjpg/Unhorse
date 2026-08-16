extends Node

@export var player : Player

##this is a Node2D that represents where the claw should spawn by default
@export var claw_origin : Node2D 

##this is basically a library of claws, each claw should have its own index
@export var claws : Array[PackedScene] = []


var current_claw_index : int = -1 #starts at -1 just because change claw checks if its on the same claw
var claw : Claw


func _ready() -> void:
	change_claw(0) #initializes claw at start of game to be the default claw (this is temporary)



func change_claw(index : int):
	#input checking-----------------------------------------------------------
	if index < 0:
		print("claw manager: index " + str(index) + " is negative! index cannot be negative")
		return

	if index == current_claw_index: 
		print("claw manager: claw " + str(index) + " is already selected")
		return

	if index >= claws.size():
		print("claw manager: index " + str(index) + " is out of bounds")
		return

	#start actually changing the claw-----------------------------------------
	current_claw_index = index
	print("claw manager: changing player's claw to claw " + str(index) + ", " + claws[index].resource_path)

	#finding where to spawn claw------------------------------------
	var spawn_location : Vector2 = Vector2.ZERO #initializes to 0,0
	if claw_origin: #sets spawn_location to claw origin if one is set
		spawn_location = claw_origin.global_position

	#deleting old claw-----------------------------------------------------------------
	if claw: 
		#spawn_location = claw.global_position #this is for spawning at old claw location but this might break if we make different sized claws
		claw.queue_free()

	#creating new claw and setting player's reference to claw-----------------------------------
	claw = claws[index].instantiate()
	claw.global_position = spawn_location 
	add_child(claw) #claw needs to be child of something to exist in the scene
	player.set_claw(claw)




func _process(delta: float) -> void:
	debug()




func debug(): #called every frame, can be used to add inputs or print statements to check on stuff
	if Input.is_action_just_pressed("debug"): #I set the debug buttong to the "p" key
		#print("debug: changing claw to claw 1")
		change_claw(1)
