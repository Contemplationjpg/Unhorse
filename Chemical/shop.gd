extends Control

@export var large_holes : Array[Hole] = []
@export var medium_holes : Array[Hole] = []
@export var small_holes : Array[Hole] = []

@export var bumper_scene : PackedScene
@export var player : Player

#this script is supposed to manage the shop buttons and refer to ChemicalGameManager to say what we are purchasing
var gm: ChemicalGameManager = ChemicalGameManager
var current_scroll_value: int = 0

#prices
var play_price: int = 100
var restock_price: int = 0

#upgrade amounts
var mid_hole_upgrades: int = 0
var small_hole_upgrades: int = 0
var loot_base_points_upgrades: int = 0
var loot_bounce_bonus_upgrades: int = 0
var claw_move_speed_upgrades: int = 0

var loot_current_point_upgrade_amount: int = 0
var loot_current_bounce_bonus_upgrade_amount: int = 0

var claw_current_move_speed_upgrade_amount: int = 1

#owned claws
var excavator_owned = false




func _ready() -> void:
	gm.save_loaded.connect(on_save_loaded)
	return


func _on_buy_play_pressed() -> void:
	var spendable = gm.spend_points(play_price)
	if spendable == true:
		gm.gain_plays(1)


func _on_restock_pressed() -> void:
	if gm.spend_points(restock_price):
		gm.start_restock.emit()

#upgrades---------------------------------------------------------

func _on_mid_hole_multiplier_pressed() -> void:
	var button = $SidePanel/ShopColumns/ShopRow/MidHoleMultiplier
	
	var price: int = 500
	var new_price: int = 2000
	var amount_to_upgrade_by: int = 1
	var next_amount_to_upgrade_by: int = 1
	
	#price is current price of upgrade
	#new_price is what the price will become once bought
	#amount_to_upgrade_by in case we want to up by different values
	#next_amount_to_upgrade_by same idea as new_price
	
	match mid_hole_upgrades:
		1: 
			price = 2000 
			new_price = 4500
			amount_to_upgrade_by = 1
			next_amount_to_upgrade_by = 1
		2: 
			price = 4500
			new_price = 8000
			amount_to_upgrade_by = 1
			next_amount_to_upgrade_by = 1
		3: 
			price = 8000
			new_price = 0
			amount_to_upgrade_by = 1
			next_amount_to_upgrade_by = 0
		
	var spendable = gm.spend_points(price)
	if spendable == true:
		for i in medium_holes:
			i.point_modifier += amount_to_upgrade_by
			
		gm.update_holes.emit()
		
		
		mid_hole_upgrades += 1
		if new_price == 0:
			button.text = "Mid Hole Mult Max"
			button.disabled = true
		else:
			button.text = "Mid Hole" + "\n+ " + str(next_amount_to_upgrade_by) + " Mult" + "\nCost: " + str(new_price)

func _on_small_hole_multiplier_pressed() -> void:
	var button = $SidePanel/ShopColumns/ShopRow/SmallHoleMultiplier
	
	var price: int = 3000
	var new_price: int = 9000
	var amount_to_upgrade_by: int = 2
	var next_amount_to_upgrade_by: int = 3
	
	match small_hole_upgrades:
		1: 
			price = 9000 
			new_price = 15000
			amount_to_upgrade_by = 3
			next_amount_to_upgrade_by = 2
		2: 
			price = 15000
			new_price = 30000
			amount_to_upgrade_by = 2
			next_amount_to_upgrade_by = 1
		3: 
			price = 40000
			new_price = 0
			amount_to_upgrade_by = 1
			next_amount_to_upgrade_by = 0
		
	var spendable = gm.spend_points(price)
	if spendable == true:
		for i in small_holes:
			i.point_modifier += amount_to_upgrade_by

		gm.update_holes.emit()

		
		small_hole_upgrades += 1
		if new_price == 0:
			button.text = "Small Hole Mult Max"
			button.disabled = true
		else:
			button.text = "Small Hole" + "\n+ " + str(next_amount_to_upgrade_by) + " Mult" + "\nCost: " + str(new_price)


func _on_loot_base_points_pressed() -> void:
	var button = $SidePanel/ShopColumns/ShopRow2/LootBasePoints
	
	var price: int = 50
	var new_price: int = 200
	var amount_to_upgrade_by: int = 10
	var next_amount_to_upgrade_by: int = 20
	
	match loot_base_points_upgrades:
		1: 
			price = 200
			new_price = 250
			amount_to_upgrade_by = 20
			next_amount_to_upgrade_by = 10
		2: 
			price = 250
			new_price = 400
			amount_to_upgrade_by = 10
			next_amount_to_upgrade_by = 30
		3: 
			price = 400
			new_price = 0
			amount_to_upgrade_by = 30
		
	var spendable = gm.spend_points(price)
	if spendable == true:
		loot_current_point_upgrade_amount += amount_to_upgrade_by
		gm.loot_current_point_upgrade_amount = loot_current_point_upgrade_amount
		gm.update_loot.emit()
		loot_base_points_upgrades += 1
		if new_price == 0:
			button.text = "Loot Value Max"
			button.disabled = true
		else:
			button.text = "Loot Value " + "\n+ "+ str(next_amount_to_upgrade_by) + " Points" + "\nCost:" + str(new_price)


func _on_loot_bounce_bonus_pressed() -> void:
	var button = $SidePanel/ShopColumns/ShopRow2/LootBounceBonus
	
	var price: int = 100
	var new_price: int = 250
	var amount_to_upgrade_by: int = 1
	var next_amount_to_upgrade_by: int = 2
	
	match loot_bounce_bonus_upgrades:
		1:
			price = 250
			new_price = 500
			amount_to_upgrade_by = 2
			next_amount_to_upgrade_by = 1
		2:
			price = 500
			new_price = 0
			amount_to_upgrade_by = 1
			next_amount_to_upgrade_by = 0
			
	var spendable = gm.spend_points(price)
	if spendable == true:
		loot_current_bounce_bonus_upgrade_amount += amount_to_upgrade_by
		gm.loot_current_bounce_bonus_upgrade_amount = loot_current_bounce_bonus_upgrade_amount

		gm.update_loot.emit()
		loot_bounce_bonus_upgrades += 1
		if new_price == 0:
			button.text = "Bounce Bonus Max"
			button.disabled = true
		else:
			button.text = "Bounce Bonus " + "\n+ "+ str(next_amount_to_upgrade_by) + " Mult" + "\nCost:" + str(new_price)


func _on_claw_move_speed_pressed() -> void:
	var button = $SidePanel/ShopColumns/ShopRow3/ClawMoveSpeed
	
	var price: int = 200
	var new_price: int = 500
	var amount_to_upgrade_by: int = 2
	var next_amount_to_upgrade_by: int = 2
	
	match claw_move_speed_upgrades:
		1:
			price = 500
			new_price = 0
			amount_to_upgrade_by = 2
			next_amount_to_upgrade_by = 0
			
	var spendable = gm.spend_points(price)
	if spendable == true:
		claw_current_move_speed_upgrade_amount += amount_to_upgrade_by
		gm.claw_current_move_speed_upgrade_amount = claw_current_move_speed_upgrade_amount
		claw_move_speed_upgrades += 1
		
		
		if new_price == 0:
			button.text = "Claw Move Speed Max"
			button.disabled = true
		else:
			button.text = "Claw Move Speed " + "\nx "+ str(next_amount_to_upgrade_by) + "\nCost:" + str(new_price)

func _on_spawn_bumper_pressed() -> void:
	var price = 500
	if gm.spend_points(price):
		spawn_bumper()
	pass # Replace with function body.

func spawn_bumper():
	var bumper = bumper_scene.instantiate()
	player.add_child(bumper)
	bumper.global_position = Vector2.ZERO
	
	
#claw switching--------------------------------------------


func _on_base_claw_pressed() -> void:
	var claw_manager = $"../../../ClawManager"
	
	if not player.claw.grabbing and not player.claw.holding:
		claw_manager.change_claw(0)


func _on_excavator_pressed() -> void:
	var claw_manager = $"../../../ClawManager"
	var button = $SidePanel/ShopColumns/ClawScrollShopRow/ShopRow/Excavator 
	
	if not excavator_owned:
		var price = 10000
		if gm.spend_points(price):
			excavator_owned = true
			button.text = "Excavator"
	
	if excavator_owned and not player.claw.grabbing and not player.claw.holding:
		claw_manager.change_claw(1)
	


func _on_shop_left_pressed() -> void:
	var scroll_shop = $SidePanel/ShopColumns/ClawScrollShopRow
	scroll_shop.scroll_horizontal += -130

func _on_shop_right_pressed() -> void:
	var scroll_shop = $SidePanel/ShopColumns/ClawScrollShopRow
	scroll_shop.scroll_horizontal += 130



#load save data--------------------------------------------------------------

func on_save_loaded():
	loot_current_point_upgrade_amount = gm.loot_current_point_upgrade_amount
	loot_current_bounce_bonus_upgrade_amount = gm.loot_current_bounce_bonus_upgrade_amount

	claw_current_move_speed_upgrade_amount = gm.claw_current_move_speed_upgrade_amount

	#owned claws
	excavator_owned = gm.excavator_owned
