class_name LootSpawner
extends Node

@export var loot_types : Array[Resource]
@export var special_loot_types : Array[Resource]
@export var unhorse_scene : PackedScene
@export var default_loot : PackedScene
@export var loot_holder : Node2D #parent of all LootSpawnPoints
@export var claw_origin : Node2D
@export var player : Player

@export var bomb_hud : TextureRect

@export var normal_spawn_attempts : int = 10
@export var special_spawn_attempts : int = 3
@export var spawn_radius : float = 30.0
@export var bomb_cooldown : float = 10
@export var restock_cooldown : float = 2

@onready var spawn_points : Array[Node] = loot_holder.get_children()
@onready var gm : ChemicalGameManager = ChemicalGameManager

var restocking : bool = false

var bomb_strength_upgrade : int = 0
var bomb_strength_upgrade_amount : float = 1.0

var bomb_cooldown_upgrade : int = 0 
var bomb_cooldown_upgrade_amount : float = 0.0

var spawn_upgrade : int = 0
var spawn_upgrade_amount : int = 0

var rarity_upgrade : int = 0
var rarity_upgrade_amount : int = 0

var bomb_cooldown_timer : float = 0
var restock_cooldown_timer : float = 0

func _ready() -> void:
	gm.start_restock.connect(restock)
	gm.update_upgrades.connect(update_upgrades)
	update_upgrades()
	spawn_all_loot_types()
	gm.bomb_on_cooldown.connect(dim_bomb_cooldown_hud)
	gm.bomb_off_cooldown.connect(light_bomb_cooldown_hud)
	gm.reset_save_file.connect(force_restock)

func _process(delta: float) -> void:
	if bomb_cooldown_timer > 0:
		bomb_cooldown_timer -= delta
	if restock_cooldown_timer > 0:
		restock_cooldown_timer -= delta

	if bomb_cooldown_timer <= 0:
		gm.bomb_off_cooldown.emit()
		if Input.is_action_just_pressed("bomb"):
			give_player_bomb()

	if restock_cooldown_timer <= 0:
		gm.restock_off_cooldown.emit()
		if Input.is_action_just_pressed("restock"):
			restock()
		


func give_player_bomb():
	if player.claw:
		var new_unhorse = unhorse_scene.instantiate()
		add_child(new_unhorse)
		player.claw.force_to_hold(new_unhorse)
		new_unhorse.impulse_amount*=bomb_strength_upgrade_amount
		bomb_cooldown_timer = bomb_cooldown-bomb_cooldown_upgrade_amount
		gm.bomb_on_cooldown.emit()


func dim_bomb_cooldown_hud():
	bomb_hud.self_modulate.v = 0.4

func light_bomb_cooldown_hud():
	bomb_hud.self_modulate.v = 1


func force_restock():
	restocking = true
	clear_all_loot()
	await get_tree().create_timer(0.2).timeout
	spawn_all_loot_types()
	restocking = false
	restock_cooldown_timer = restock_cooldown
	gm.restock_on_cooldown.emit()




func restock():
	if restocking:
		return
	restocking = true
	clear_all_loot()
	await get_tree().create_timer(0.2).timeout
	spawn_all_loot_types()
	restocking = false
	restock_cooldown_timer = restock_cooldown
	gm.restock_on_cooldown.emit()


func clear_all_loot():
	gm.clear_all_loot.emit()


func spawn_all_loot_types():
	spawn_special_loot()
	drop_loot_around_claw_origin()

func drop_loot_around_claw_origin():
	var chosen_spawn_point : Vector2
	var chosen_loot : PackedScene = null
	var rng : float
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

	for i in range(normal_spawn_attempts + spawn_upgrade):
		rng = randi_range(0,1)

		var spawn_rare : bool = false
		print("rarity upgrade amount: " + str(rarity_upgrade_amount))
		print("rare spawn chance: " + str((1.0+rarity_upgrade_amount)/6))
		if rng <= ((1.0+rarity_upgrade_amount)/6):
			spawn_rare = true
		
		if spawn_rare:
			rng = randi_range(0,additive_rng_threshold-1)
			var index : int = 0
			while (not chosen_loot):
				#print("comparing to index " + str(index) + ", " + str(loot_rng_values[index]))
				if rng >= loot_rng_values[index]:
					index += 1
				else:
					chosen_loot = loot_types[index].loot_scene
					#print("spawning " + chosen_loot.resource_path)
		else:
			chosen_loot = default_loot

		#choosing spawn point around claw origin
		var rngi : float = randi_range(-spawn_radius, spawn_radius)
		var x_offset : float = rngi
		rngi = randi_range(-spawn_radius, spawn_radius)
		var y_offset : float = rngi
		
		chosen_spawn_point = claw_origin.global_position + Vector2(x_offset, y_offset)

		#spawning the loot-----------------
		var new_loot = chosen_loot.instantiate()
		chosen_loot = null
		claw_origin.add_child(new_loot)
		new_loot.position = chosen_spawn_point	
		new_loot.force_to_be_in_air()





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


func update_upgrades():
	spawn_upgrade = gm.loot_spawn_upgrade
	match spawn_upgrade:
		0:
			spawn_upgrade_amount = 0
		1:
			spawn_upgrade_amount = 3
		2:
			spawn_upgrade_amount = 5
		_:
			spawn_upgrade_amount = 10
			

	rarity_upgrade = gm.loot_rarity_upgrade
	match rarity_upgrade:
		0:
			rarity_upgrade_amount = 1
		1:
			rarity_upgrade_amount = 2
		2:
			rarity_upgrade_amount = 3
		_:
			rarity_upgrade_amount = 5

	bomb_strength_upgrade = gm.bomb_strength_upgrade
	match bomb_strength_upgrade:
		0:
			bomb_strength_upgrade_amount = 1
		1:
			bomb_strength_upgrade_amount = 2
		2:
			bomb_strength_upgrade_amount = 3
		_:
			bomb_strength_upgrade_amount = 4

	bomb_cooldown_upgrade = gm.bomb_cooldown_upgrade
	match bomb_cooldown_upgrade:
		0:
			bomb_cooldown_upgrade_amount = 0
		1:
			bomb_cooldown_upgrade_amount = 2
		2:
			bomb_cooldown_upgrade_amount = 4
		_:
			bomb_cooldown_upgrade_amount = 7


	
