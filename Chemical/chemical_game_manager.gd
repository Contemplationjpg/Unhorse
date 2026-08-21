extends Node


const VERSION : String = "jam 0.1"


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

signal update_loot()
signal update_holes()
signal update_claw()

signal start_restock()
signal clear_all_loot()

signal request_claw()
signal send_claw(claw : Claw)

#resources--------------------------------
var points : int = 500
var plays : int = 3
var spins : int = 3

#upgrade amounts--------------------------
var loot_current_point_upgrade_amount: int = 0
var loot_current_bounce_bonus_upgrade_amount: int = 0

var claw_current_move_speed_upgrade_amount: int = 1


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

func get_version() -> String:
	return VERSION


#update default_save and save_dict whenever adding new important game variable like resource or upgrades
var default_save := {
	"version" : get_version(),
	"points" : points,
	"plays" : plays,
	"spins" : spins,
	
	"loot_point_upgrade" : loot_current_point_upgrade_amount,
	"loot_bounce_bonus_upgrade" : loot_current_bounce_bonus_upgrade_amount,
	
	"claw_move_speed_upgrade" : claw_current_move_speed_upgrade_amount,
	}

var save_dict := {
	"version" : get_version(),
	"points" : points,
	"plays" : plays,
	"spins" : spins,
	
	"loot_point_upgrade" : loot_current_point_upgrade_amount,
	"loot_bounce_bonus_upgrade" : loot_current_bounce_bonus_upgrade_amount,
	
	"claw_move_speed_upgrade" : claw_current_move_speed_upgrade_amount,
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

	save_dict["loot_point_upgrade"] = loot_current_point_upgrade_amount
	save_dict["loot_bounce_bonus_upgrade"] = loot_current_bounce_bonus_upgrade_amount

	save_dict["claw_move_speed_upgrade"] = claw_current_move_speed_upgrade_amount
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
	save_dict = save_data.duplicate() #set our save dict to a duplicate of the new save data
	#loading each current game value with the new save dict data------------
	points = save_dict["points"]
	plays = save_dict["plays"]
	spins = save_dict["spins"]

	loot_current_point_upgrade_amount = save_dict["loot_point_upgrade"]
	loot_current_bounce_bonus_upgrade_amount = save_dict["loot_bounce_bonus_upgrade"]

	claw_current_move_speed_upgrade_amount = save_dict["claw_move_speed_upgrade"]
	on_any_update.emit()
	print("save loaded.")





func clear_save_data():
	load_data_from_save(default_save) #makes current save the default game state
	save_game() #saves the game as the default game state
	just_reset_save_file.emit()







