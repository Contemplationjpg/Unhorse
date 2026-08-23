extends Node


const VERSION : String = "jam 0.21"


#signals for whenever any change to stats happens in case we want to add effects that pay attention to this, so please use the correct resource gain/spend functions
signal on_gain_points(points_gained : int)
signal on_gain_plays(plays_gained : int)
signal on_gain_spins(spins_gained : int)

signal on_spend_points(points_spent : int)
signal on_spend_plays(plays_spent : int)
signal on_spend_spins(spins_spent : int)

signal on_any_update() #this "on_any_update" signal is intended for things like updating ui but tbh you can go wild with this if you want

signal on_loot_scored(position : Vector2, amount : int)
signal on_loot_bonus_update(position : Vector2, bonus : float)

signal on_explosion(position : Vector2, scale : float)

signal update_upgrades()

signal start_restock()
signal clear_all_loot()

signal request_claw()
signal send_claw(claw : Claw)

signal bomb_on_cooldown()
signal bomb_off_cooldown()

signal restock_on_cooldown()
signal restock_off_cooldown()

#resources--------------------------------
var points : int = 500
var plays : int = 3
var spins : int = 3

#upgrade amounts--------------------------

var hole_upgrade : int = 0
var loot_value_upgrade : int = 0

var loot_speed_upgrade : int = 0
var loot_bonus_upgrade : int = 0

var loot_spawn_upgrade : int = 0
var loot_rarity_upgrade : int = 0

var bomb_strength_upgrade : int = 0
var bomb_cooldown_upgrade : int = 0

var claw_new_owned : bool = false
var claw_excavator_owned : bool = false
var claw_ufo_owned : bool = false
var claw_cloner_owned : bool = false


#settings----------------------------------
var master_volume : float = 0.7
var music_volume: float = 0.7
var sfx_volume: float = 0.7


func save_music_volumes(bus_index, value):
	match bus_index:
		0:
			#print(str(value))
			master_volume = value
		1:
			music_volume = value
		2: 
			sfx_volume = value

func get_music_volumes(bus_index) -> float:
	match bus_index:
		0:
			return master_volume
		1:
			return music_volume
		2: 
			return sfx_volume
		_:
			return 1.0


	


#gaining resource-------------------------
func gain_points(p : int):
	points += p
	on_gain_points.emit(p)
	on_any_update.emit()

func gain_plays(p : int):
	plays += p
	on_gain_plays.emit(p)
	on_any_update.emit()

func gain_spins(s : int):
	spins += s
	on_gain_spins.emit(s)
	on_any_update.emit()


#spending resource (input should be always be positive number that will be subtracted from the total)------------------------
	#all of these functions return true if successfully spent resource, and return false if you don't have enough
func spend_points(p : int) -> bool:
	if p > points:
		return false
	points -= p
	on_spend_points.emit(p)
	on_any_update.emit()
	return true

func spend_plays(p : int) -> bool:
	if p > plays:
		return false
	plays -= p
	on_spend_plays.emit(p)
	on_any_update.emit()
	return true

func spend_spins(s : int) -> bool:
	if s > spins:
		return false
	spins -= s
	on_spend_spins.emit(s)
	on_any_update.emit()
	return true










#save/load system--------------------------------------------------------------------------------

const SAVE_PATH = "user://"

signal game_saving()
signal game_saved()

signal reset_save_file() #for other scripts to call
signal just_reset_save_file() #for us to call

signal save_loading()
signal save_loaded()

func _ready():
	load_save()
	reset_save_file.connect(clear_save_data) #reset_save_file should be called by other scripts, namely the settings with the reset data button
	on_any_update.connect(save_game) #should autosave whenever data changes
	update_upgrades.connect(save_game) #should autosave whenever buying upgrade

func get_version() -> String:
	return VERSION


#update default_save and save_dict whenever adding new important game variable like resource or upgrades
var default_save := {
	"version" : get_version(),
	"points" : points,
	"plays" : plays,
	"spins" : spins,
	
	"hole_upgrade" : hole_upgrade,
	"loot_value_upgrade" : loot_value_upgrade,

	"loot_speed_upgrade" :  loot_speed_upgrade, 
	"loot_bonus_upgrade" : loot_bonus_upgrade, 

	"loot_spawn_upgrade" : loot_spawn_upgrade, 
	"loot_rarity_upgrade" : loot_rarity_upgrade, 

	"bomb_strength_upgrade" : bomb_strength_upgrade,
	"bomb_cooldown_upgrade" : bomb_cooldown_upgrade,


	"claw_new_owned" : claw_new_owned, 
	"claw_excavator_owned" : claw_excavator_owned, 
	"claw_ufo_owned" : claw_ufo_owned, 
	"claw_cloner_owned" : claw_cloner_owned, 

	"master_volume" : master_volume,
	"music_volume" : music_volume,
	"sfx_volume" : sfx_volume,

	}

var save_dict := {
	"version" : get_version(),
	"points" : points,
	"plays" : plays,
	"spins" : spins,

	"hole_upgrade" : hole_upgrade,
	"loot_value_upgrade" : loot_value_upgrade,

	"loot_speed_upgrade" :  loot_speed_upgrade, 
	"loot_bonus_upgrade" : loot_bonus_upgrade, 

	"loot_spawn_upgrade" : loot_spawn_upgrade, 
	"loot_rarity_upgrade" : loot_rarity_upgrade, 
	
	"bomb_strength_upgrade" : bomb_strength_upgrade,
	"bomb_cooldown_upgrade" : bomb_cooldown_upgrade,

	"claw_new_owned" : claw_new_owned, 
	"claw_excavator_owned" : claw_excavator_owned, 
	"claw_ufo_owned" : claw_ufo_owned, 
	"claw_cloner_owned" : claw_cloner_owned,

	"master_volume" : master_volume,
	"music_volume" : music_volume,
	"sfx_volume" : sfx_volume,

	}



func get_save_dict() -> Dictionary:
	return save_dict





func save_game():
	game_saving.emit()
	var path = (SAVE_PATH + "/unhorse_data.save")
	#print("saving to: " + path)

	#saving each dictionary value-------------------------------------
	save_dict["version"] = get_version()
	save_dict["points"] = points
	save_dict["plays"] = plays
	save_dict["spins"] = spins

	save_dict["hole_upgrade"] = hole_upgrade
	save_dict["loot_value_upgrade"] = loot_value_upgrade

	save_dict["loot_speed_upgrade"] =  loot_speed_upgrade 
	save_dict["loot_bonus_upgrade"] = loot_bonus_upgrade 

	save_dict["loot_spawn_upgrade"] = loot_spawn_upgrade 
	save_dict["loot_rarity_upgrade"] = loot_rarity_upgrade 


	save_dict["bomb_strength_upgrade"] = bomb_strength_upgrade
	save_dict["bomb_cooldown_upgrade"] = bomb_cooldown_upgrade

	save_dict["claw_new_owned"] = claw_new_owned 
	save_dict["claw_excavator_owned"] = claw_excavator_owned 
	save_dict["claw_ufo_owned"] = claw_ufo_owned 
	save_dict["claw_cloner_owned"] = claw_cloner_owned

	save_dict["master_volume"] = master_volume
	save_dict["music_volume"] = music_volume
	save_dict["sfx_volume"] = sfx_volume



	#done saving each dictionary value-----------------------------
	
	var save_file = FileAccess.open(path, FileAccess.WRITE)
	var json_string = JSON.stringify(get_save_dict()) #stores dictionary, save_dict, into a json file
	save_file.store_line(json_string)  #stores the json file info into user://saves/save#.save
	game_saved.emit()





#loads save data from the save path into a dictionary, then copies the data into our current save dictionary, then loads the new data into our current game data
func load_save():
	save_loading.emit()
	var path = (SAVE_PATH + "/unhorse_data.save")

	if not FileAccess.file_exists(path): #if you don't have a save, make a new save
		clear_save_data()
		return

	print("save data found")
	var save_file = FileAccess.open(path,FileAccess.READ)
	var node_data
	while save_file.get_position() < save_file.get_length(): #reads all lines of the json files if somehow more than 1 line
		var json_string = save_file.get_line() 
		var json = JSON.new()
		json.parse(json_string)
		#var parse_result = json.parse(json_string) #leaving here in case we need a reference to the parse result
		node_data = json.get_data() 
	save_dict = node_data
	print(node_data)
	
	print("loading save")
	load_data_from_save(save_dict)
	save_loaded.emit()





#gets the save data from a dictionary and copies the data into our save dictionary
func load_data_from_save(save_data : Dictionary):
	var new_data
	if not save_data.get("version", "") == default_save["version"]:
		new_data = update_handler(save_data)
	else:
		new_data = save_data.duplicate()
	save_dict = new_data #set our save dict to a duplicate of the new save data
	#loading each current game value with the new save dict data------------
	points = save_dict["points"]
	plays = save_dict["plays"]
	spins = save_dict["spins"]
	
	hole_upgrade = save_dict["hole_upgrade"]
	loot_value_upgrade = save_dict["loot_value_upgrade"]

	loot_speed_upgrade = save_dict["loot_speed_upgrade"]
	loot_bonus_upgrade = save_dict["loot_bonus_upgrade"]

	loot_spawn_upgrade = save_dict["loot_spawn_upgrade"]
	loot_rarity_upgrade = save_dict["loot_rarity_upgrade"]

	bomb_strength_upgrade = save_dict["bomb_strength_upgrade"]
	bomb_cooldown_upgrade = save_dict["bomb_cooldown_upgrade"]

	claw_new_owned = save_dict["claw_new_owned"]
	claw_excavator_owned = save_dict["claw_excavator_owned"]
	claw_ufo_owned = save_dict["claw_ufo_owned"]
	claw_cloner_owned = save_dict["claw_cloner_owned"]

	master_volume = save_dict["master_volume"]
	music_volume = save_dict["music_volume"]
	sfx_volume = save_dict["sfx_volume"]


	on_any_update.emit()
	print("save loaded.")

func update_handler(save_data : Dictionary) -> Dictionary:
	print("handling update")
	var updated_save : Dictionary
	updated_save["points"] = save_data.get("points", default_save["points"])
	updated_save["plays"] = save_data.get("plays", default_save["plays"])
	updated_save["spins"] = save_data.get("spins", default_save["spins"])
	
	updated_save["hole_upgrade"] = save_data.get("hole_upgrade", default_save["hole_upgrade"])
	updated_save["loot_value_upgrade"] = save_data.get("loot_value_upgrade", default_save["loot_value_upgrade"])

	updated_save["loot_speed_upgrade"] = save_data.get("loot_speed_upgrade", default_save["loot_speed_upgrade"])
	updated_save["loot_bonus_upgrade"] = save_data.get("loot_bonus_upgrade", default_save["loot_bonus_upgrade"])

	updated_save["loot_spawn_upgrade"] = save_data.get("loot_spawn_upgrade", default_save["loot_spawn_upgrade"])
	updated_save["loot_rarity_upgrade"] = save_data.get("loot_rarity_upgrade", default_save["loot_rarity_upgrade"])

	updated_save["bomb_strength_upgrade"] = save_data.get("bomb_strength_upgrade", default_save["bomb_strength_upgrade"])
	updated_save["bomb_cooldown_upgrade"] = save_data.get("bomb_cooldown_upgrade", default_save["bomb_cooldown_upgrade"])

	updated_save["claw_new_owned"] = save_data.get("claw_new_owned", default_save["claw_new_owned"])
	updated_save["claw_excavator_owned"] = save_data.get("claw_excavator_owned", default_save["claw_excavator_owned"])
	updated_save["claw_ufo_owned"] = save_data.get("claw_ufo_owned", default_save["claw_ufo_owned"])
	updated_save["claw_cloner_owned"] = save_data.get("claw_cloner_owned", default_save["claw_ufo_owned"])
	
	
	updated_save["master_volume"] = save_data.get("master_volume", default_save["master_volume"])
	updated_save["music_volume"] = save_data.get("music_volume", default_save["music_volume"])
	updated_save["sfx_volume"] = save_data.get("sfx_volume", default_save["sfx_volume"])
	
	return updated_save




func clear_save_data():
	var saved_master_vol : float = master_volume
	var saved_music_vol : float = music_volume
	var saved_sfx_vol : float = sfx_volume
	load_data_from_save(default_save.duplicate()) #makes current save the default game state
	master_volume = saved_master_vol
	music_volume = saved_music_vol
	sfx_volume = saved_sfx_vol
	save_game() #saves the game as the default game state (except remembers the volume settings)
	just_reset_save_file.emit()
	on_any_update.emit()
	update_upgrades.emit()
