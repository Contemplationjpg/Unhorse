class_name LootSpawner
extends Node

@export var loot_types : Array[Resource]
@export var special_loot_types : Array[Resource]
@export var loot_holder : Node2D #parent of all LootSpawnPoints

@export var normal_spawn_attempts : int = 10
@export var special_spawn_attempts : int = 3


@onready var spawn_points : Array[Node] = loot_holder.get_children()
@onready var gm : ChemicalGameManager = ChemicalGameManager

var restocking : bool = false

func _ready() -> void:
	gm.start_restock.connect(restock)
	spawn_all_loot_types()

func restock():
	if restocking:
		return
	restocking = true
	clear_all_loot()
	await get_tree().create_timer(0.2).timeout
	spawn_all_loot_types()
	restocking = false


func clear_all_loot():
	gm.clear_all_loot.emit()


func spawn_all_loot_types():
	spawn_special_loot()
	spawn_normal_loot()


func spawn_normal_loot(specified_amount : int = 0):
	var chosen_spawn_point : Node
	var chosen_loot : PackedScene = null
	var attempt_amount
	if specified_amount > 0:
		attempt_amount = specified_amount
	else:
		attempt_amount = normal_spawn_attempts

	#set up loot table
		#how this rng works: 	each loot corresponds to a number range, size depending on rng value
		#						roll rng number then if rng is within a loot's number range, spawn that loot
	var loot_rng_values : Array[int] = [] #contains values for deciding which loot to spawn
	var additive_rng_threshold : int = 0
	for i in loot_types:
		if i.loot_rarity > 0:
			additive_rng_threshold += i.loot_rarity
		loot_rng_values.append(int(additive_rng_threshold))
	#print(loot_rng_values)

	#attempt to spawn loot
	for i in range(attempt_amount):
		#pick a spawnpoint
		var rng = randi_range(0, spawn_points.size()-1)
		chosen_spawn_point = spawn_points[rng]
		if chosen_spawn_point.get_child_count() < 1:
			#deciding on which loot to spawn-------------------------
			rng = randi_range(0,additive_rng_threshold-1)
			#print("rng for picking loot is " + str(rng))
			var index : int = 0
			while (not chosen_loot):
				#print("comparing to index " + str(index) + ", " + str(loot_rng_values[index]))
				if rng >= loot_rng_values[index]:
					index += 1
				else:
					chosen_loot = loot_types[index].loot_scene
					#print("spawning " + chosen_loot.resource_path)
	
			#spawning the loot-----------------
			var new_loot = chosen_loot.instantiate()
			chosen_loot = null
			chosen_spawn_point.add_child(new_loot)
			new_loot.position = Vector2.ZERO	





func spawn_special_loot(specified_amount : int = 0):
	var chosen_spawn_point : Node
	var chosen_loot : PackedScene = null
	var attempt_amount
	if specified_amount > 0:
		attempt_amount = specified_amount
	else:
		attempt_amount = special_spawn_attempts

	#set up loot table
		#how this rng works: 	each loot corresponds to a number range, size depending on rng value
		#						roll rng number then if rng is within a loot's number range, spawn that loot
	var loot_rng_values : Array[int] = [] #contains values for deciding which loot to spawn
	var additive_rng_threshold : int = 0
	for i in special_loot_types:
		if i.loot_rarity > 0:
			additive_rng_threshold += i.loot_rarity
		loot_rng_values.append(int(additive_rng_threshold))
	#print(loot_rng_values)

	#attempt to spawn loot
	for i in range(attempt_amount):
		#pick a spawnpoint
		var rng = randi_range(0, spawn_points.size()-1)
		chosen_spawn_point = spawn_points[rng]
		if chosen_spawn_point.get_child_count() < 1:
			#deciding on which loot to spawn-------------------------
			rng = randi_range(0,additive_rng_threshold-1)
			#print("rng for picking loot is " + str(rng))
			var index : int = 0
			while (not chosen_loot):
				#print("comparing to index " + str(index) + ", " + str(loot_rng_values[index]))
				if rng >= loot_rng_values[index]:
					index += 1
				else:
					chosen_loot = special_loot_types[index].loot_scene
					#print("spawning " + chosen_loot.resource_path)
	
			#spawning the loot-----------------
			var new_loot = chosen_loot.instantiate()
			chosen_loot = null
			chosen_spawn_point.add_child(new_loot)
			new_loot.position = Vector2.ZERO	
