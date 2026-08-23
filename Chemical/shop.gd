class_name Shop
extends Control

@export var large_holes : Array[Hole] = []
@export var medium_holes : Array[Hole] = []
@export var small_holes : Array[Hole] = []

@export var claw_buttons : Array[Button] = []
@export var shop_buttons : Array[Button] = []
@export var play_button : Button
@export var restock_button : Button

@export var bumper_scene : PackedScene
@export var player : Player

#this script is supposed to manage the shop buttons and refer to ChemicalGameManager to say what we are purchasing
var gm: ChemicalGameManager = ChemicalGameManager
var current_scroll_value: int = 0

#prices
var play_price: int = 100
var restock_price: int = 0

#upgrade amounts

var hole_upgrade : int = 0
var loot_value_upgrade : int = 0

var loot_speed_upgrade : int = 0
var loot_bonus_upgrade : int = 0

var loot_spawn_upgrade : int = 0
var loot_rarity_upgrade : int = 0

var bomb_strength_upgrade : int = 0
var bomb_cooldown_upgrade : int = 0


#owned claws
var claw_new_owned : bool = false
var claw_excavator_owned : bool = false
var claw_ufo_owned : bool = false
var claw_cloner_owned : bool = false







func _ready() -> void:
	gm.save_loaded.connect(on_save_loaded)
	_connect_shop_buttons()
	on_save_loaded()
	_update_shop_buttons()
	gm.update_upgrades.connect(_update_shop_buttons)
	gm.restock_off_cooldown.connect(enable_restock)
	gm.restock_on_cooldown.connect(disable_restock)
	return


func _connect_shop_buttons():
	shop_buttons[0].pressed.connect(_on_button0)
	shop_buttons[1].pressed.connect(_on_button1)
	shop_buttons[2].pressed.connect(_on_button2)
	shop_buttons[3].pressed.connect(_on_button3)
	shop_buttons[4].pressed.connect(_on_button4)
	shop_buttons[5].pressed.connect(_on_button5)
	shop_buttons[6].pressed.connect(_on_button6)
	shop_buttons[7].pressed.connect(_on_button7)
	shop_buttons[8].pressed.connect(_on_button8)
	shop_buttons[9].pressed.connect(_on_button9)

func _update_shop_buttons():
	for i in shop_buttons:
		i.pressed.emit(true)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug"):
		#print("only update, hole upgrade = " + str(hole_upgrade))
		#print("only update, loot value upgrade = " + str(loot_value_upgrade))
		#for i in shop_buttons:
			#i.pressed.emit(true)
		#gm.gain_points(10000)
		pass

func _on_buy_play_pressed() -> void:
	var spendable = gm.spend_points(play_price)
	if spendable == true:
		gm.gain_plays(1)


func _on_restock_pressed() -> void:
	if gm.spend_points(restock_price):
		gm.start_restock.emit()

func disable_restock():
	restock_button.disabled = true

func enable_restock():
	restock_button.disabled = false


#upgrades---------------------------------------------------------


#hole upgrade
func _on_button0(only_update_text : bool = false) -> void:
	var button = shop_buttons[0]
	
	var price: int 
	var new_price: int 
	hole_upgrade = gm.hole_upgrade
	if not only_update_text:
		hole_upgrade += 1
	match hole_upgrade:
		0:
			price = 1000
			new_price = 2000
		1: 
			price = 2000
			new_price = 4000
		2:
			price = 4000
			new_price = 8000
		_: 
			price = 8000
			new_price = 0
	if not only_update_text:	
		print("hole upgrade pressed")
		if gm.spend_points(price):
			gm.hole_upgrade = hole_upgrade
		gm.update_upgrades.emit()
	else:
		print("only update, hole upgrade = " + str(hole_upgrade))
	
	#do label
	if new_price == 0:
		button.text = "Hole Upgrade\nMax"
		button.disabled = true
	else:
		button.text = "Hole Upgrade" + "\n+" + str(pow(2,hole_upgrade)) + " Mult" + "\nCost: " + str(new_price)
		button.disabled = false
	


#loot value upgrade
func _on_button1(only_update_text : bool = false) -> void:
	var button = shop_buttons[1]
	
	var price: int 
	var new_price: int 
	loot_value_upgrade = gm.loot_value_upgrade
	if not only_update_text:
		loot_value_upgrade += 1
	match loot_value_upgrade:
		0:
			price = 1000
			new_price = 2000
		1: 
			price = 2000
			new_price = 4000
		2:
			price = 4000
			new_price = 8000
		_: 
			price = 8000
			new_price = 0
	if not only_update_text:	
		print("loot value upgrade pressed")
		if gm.spend_points(price):
			gm.loot_value_upgrade = loot_value_upgrade
		gm.update_upgrades.emit()
	else:
		print("only update, loot value upgrade = " + str(loot_value_upgrade))
	
	#do label
	if new_price == 0:
		button.text = "Loot Value\nMax"
		button.disabled = true
	else:
		button.text = "Loot Upgrade" + "\nx" + str(pow(2,loot_value_upgrade)) + " Points" + "\nCost: " + str(new_price)
		button.disabled = false
	


#loot speed upgrade
func _on_button2(only_update_text : bool = false) -> void:
	var button = shop_buttons[2]

	var price: int 
	var new_price: int 
	loot_speed_upgrade = gm.loot_speed_upgrade
	if not only_update_text:
		loot_speed_upgrade += 1
	match loot_speed_upgrade:
		0:
			price = 1000
			new_price = 2000
		1: 
			price = 2000
			new_price = 4000
		2:
			price = 4000
			new_price = 8000
		_: 
			price = 8000
			new_price = 0
	if not only_update_text:	
		print("loot speed upgrade pressed")
		if gm.spend_points(price):
			gm.loot_speed_upgrade = loot_speed_upgrade
		gm.update_upgrades.emit()
	else:
		print("only update, loot speed upgrade = " + str(loot_speed_upgrade))
	
	var speed_upgrade_amount : float  = 0
	match loot_speed_upgrade:
		0:
			speed_upgrade_amount = 100
		1:
			speed_upgrade_amount = 200
		2:
			speed_upgrade_amount = 250
		_:
			pass	

	#do label
	if new_price == 0:
		button.text = "Loot Bounce Speed\nMax"
		button.disabled = true
	else:
		button.text = "Loot Bounce Speed" + "\n+" + str(speed_upgrade_amount) + " Speed" + "\nCost: " + str(new_price)
		button.disabled = false
	



#loot bounce bonus upgrade
func _on_button3(only_update_text : bool = false) -> void:
	var button = shop_buttons[3]
	
	var price: int 
	var new_price: int 
	loot_bonus_upgrade = gm.loot_bonus_upgrade
	if not only_update_text:
		loot_bonus_upgrade += 1
	match loot_bonus_upgrade:
		0:
			price = 1000
			new_price = 2000
		1: 
			price = 2000
			new_price = 4000
		2:
			price = 4000
			new_price = 8000
		_: 
			price = 8000
			new_price = 0
	if not only_update_text:	
		print("loot bonus upgrade pressed")
		if gm.spend_points(price):
			gm.loot_bonus_upgrade = loot_bonus_upgrade
		gm.update_upgrades.emit()
	else:
		print("only update, loot bonus upgrade = " + str(loot_bonus_upgrade))
	
	#do label
	if new_price == 0:
		button.text = "Bounce Bonus\nMax"
		button.disabled = true
	else:
		button.text = "Bounce Bonus" + "\n+" + str(0.5 * pow(2,loot_bonus_upgrade)) + " Mult/Bounce" + "\nCost: " + str(new_price)
		button.disabled = false
	




#loot amount upgrade
func _on_button4(only_update_text : bool = false) -> void:
	var button = shop_buttons[4]
	
	var price: int 
	var new_price: int 
	loot_spawn_upgrade = gm.loot_spawn_upgrade
	if not only_update_text:
		loot_spawn_upgrade += 1
	match loot_spawn_upgrade:
		0:
			price = 1000
			new_price = 2000
		1: 
			price = 2000
			new_price = 4000
		2:
			price = 4000
			new_price = 8000
		_: 
			price = 8000
			new_price = 0
	if not only_update_text:	
		print("loot bonus upgrade pressed")
		if gm.spend_points(price):
			gm.loot_spawn_upgrade = loot_spawn_upgrade
		gm.update_upgrades.emit()
	else:
		print("only update, loot spawn upgrade = " + str(loot_spawn_upgrade))
	
	var spawn_upgrade_amount : int = 0
	match loot_spawn_upgrade:
		0:
			spawn_upgrade_amount = 3
		1:
			spawn_upgrade_amount = 5
		2:
			spawn_upgrade_amount = 10
		_:
			spawn_upgrade_amount = 0
		


	#do label
	if new_price == 0:
		button.text = "Loot Spawn\nMax"
		button.disabled = true
	else:
		button.text = "Loot Spawn" + "\n+" + str(spawn_upgrade_amount) + " Loot" + "\nCost: " + str(new_price)
		button.disabled = false
	



#loot rarity upgrade
func _on_button5(only_update_text : bool = false) -> void:
	var button = shop_buttons[5]
	
	var price: int 
	var new_price: int 
	loot_rarity_upgrade = gm.loot_rarity_upgrade
	if not only_update_text:
		loot_rarity_upgrade += 1
	match loot_rarity_upgrade:
		0:
			price = 1000
			new_price = 2000
		1: 
			price = 2000
			new_price = 4000
		2:
			price = 4000
			new_price = 8000
		_: 
			price = 8000
			new_price = 0
	if not only_update_text:	
		print("loot bonus upgrade pressed")
		if gm.spend_points(price):
			gm.loot_rarity_upgrade = loot_rarity_upgrade
		gm.update_upgrades.emit()
	else:
		print("only update, loot spawn upgrade = " + str(loot_rarity_upgrade))
	
	var rarity_upgrade_amount : int = 0
	match loot_rarity_upgrade:
		0:
			rarity_upgrade_amount = 1
		1:
			rarity_upgrade_amount = 2
		2:
			rarity_upgrade_amount = 3
		_:
			rarity_upgrade_amount = 0
	


	#do label
	if new_price == 0:
		button.text = "Loot Rarity\nMax"
		button.disabled = true
	else:
		button.text = "Loot Rarity" + "\n+" + str(rarity_upgrade_amount) + "/6 chance" + "\nCost: " + str(new_price)
		button.disabled = false
	





#bomb strength upgrade
func _on_button6(only_update_text : bool = false) -> void:
	var button = shop_buttons[6]

	var price: int 
	var new_price: int 
	bomb_strength_upgrade = gm.bomb_strength_upgrade
	if not only_update_text:
		bomb_strength_upgrade += 1
	match bomb_strength_upgrade:
		0:
			price = 1000
			new_price = 2000
		1: 
			price = 2000
			new_price = 4000
		2:
			price = 4000
			new_price = 8000
		_: 
			price = 8000
			new_price = 0
	if not only_update_text:	
		print("loot bonus upgrade pressed")
		if gm.spend_points(price):
			gm.bomb_strength_upgrade = bomb_strength_upgrade
		gm.update_upgrades.emit()
	else:
		print("only update, loot spawn upgrade = " + str(bomb_strength_upgrade))
	

	#do label
	if new_price == 0:
		button.text = "Bomb Power\nMax"
		button.disabled = true
	else:
		button.text = "Bomb Power" + "\nx" + str(bomb_strength_upgrade) + " Power" + "\nCost: " + str(new_price)
		button.disabled = false
	






func _on_button7(only_update_text : bool = false) -> void:
	var button = shop_buttons[7]

	var price: int 
	var new_price: int 
	bomb_cooldown_upgrade = gm.bomb_cooldown_upgrade
	if not only_update_text:
		bomb_cooldown_upgrade += 1
	match bomb_cooldown_upgrade:
		0:
			price = 1000
			new_price = 2000
		1: 
			price = 2000
			new_price = 4000
		2:
			price = 4000
			new_price = 8000
		_: 
			price = 8000
			new_price = 0
	if not only_update_text:	
		print("loot bonus upgrade pressed")
		if gm.spend_points(price):
			gm.bomb_cooldown_upgrade = bomb_cooldown_upgrade
		gm.update_upgrades.emit()
	else:
		print("only update, loot spawn upgrade = " + str(bomb_cooldown_upgrade))
	

	#do label
	if new_price == 0:
		button.text = "Bomb Cooldown\nMax"
		button.disabled = true
	else:
		button.text = "Bomb Cooldown" + "\n-" + str(bomb_cooldown_upgrade) + " Seconds" + "\nCost: " + str(new_price)
		button.disabled = false




func _on_button8(only_update_text : bool = false) -> void:
	var button = shop_buttons[8]
	var price = 500
	if not only_update_text:
		if gm.spend_points(price):
			spawn_bumper()
	button.text = "Investment\nBumper\nCOST:500"
	pass # Replace with function body.

func spawn_bumper():
	var bumper = bumper_scene.instantiate() as Bumper
	player.add_child(bumper)
	bumper.global_position = Vector2.ZERO
	var rng1 : float = randf_range(-1,1)
	var rng2 : float = randf_range(-1,1)
	bumper.linear_velocity = (Vector2(rng1,rng2).normalized()*5)
	



func _on_button9(only_update_text : bool = false) -> void:
	var button = shop_buttons[9]
	if not only_update_text:	
			print("UNHORSE")
	button.text = "unhorse"
	





#claw switching--------------------------------------------


func _on_base_claw_pressed() -> void:
	var claw_manager = $"../../../ClawManager"
	
	if not player.claw.grabbing and not player.claw.holding:
		claw_manager.change_claw(0)


func _on_excavator_pressed() -> void:
	var claw_manager = $"../../../ClawManager"
	var button = $SidePanel/ShopColumns/ClawScrollShopRow/ShopRow/Excavator 
	
	if not claw_excavator_owned:
		var price = 10000
		if gm.spend_points(price):
			claw_excavator_owned = true
			gm.claw_excavator_owned = claw_excavator_owned
			button.text = "Excavator"
	
	if claw_excavator_owned and not player.claw.grabbing and not player.claw.holding:
		claw_manager.change_claw(1)
	


func _on_shop_left_pressed() -> void:
	var scroll_shop = $SidePanel/ShopColumns/ClawScrollShopRow
	scroll_shop.scroll_horizontal += -130

func _on_shop_right_pressed() -> void:
	var scroll_shop = $SidePanel/ShopColumns/ClawScrollShopRow
	scroll_shop.scroll_horizontal += 130





#load save data--------------------------------------------------------------

func on_save_loaded():
	#upgrade amounts
	hole_upgrade = gm.hole_upgrade
	loot_value_upgrade = gm.loot_value_upgrade

	loot_speed_upgrade = gm.loot_speed_upgrade 
	loot_bonus_upgrade = gm.loot_bonus_upgrade 

	loot_spawn_upgrade = gm.loot_spawn_upgrade 
	loot_rarity_upgrade = gm.loot_rarity_upgrade 

	#owned claws
	claw_new_owned = gm.claw_new_owned 
	claw_excavator_owned = gm.claw_excavator_owned 
	claw_ufo_owned = gm.claw_ufo_owned 
	claw_cloner_owned = gm.claw_cloner_owned 

	_update_shop_buttons()
