extends Control

#this script is supposed to manage the shop buttons and refer to ChemicalGameManager to say what we are purchasing
var gm: ChemicalGameManager = ChemicalGameManager

#prices
var play_price: int = 5
var restock_price: int = 10

#upgrade amounts
var mid_hole_upgrades: int = 0
var small_hole_upgrades: int = 0

func _ready() -> void:
	return


func _on_buy_play_pressed() -> void:
	var spendable = gm.spend_points(play_price)
	if spendable == true:
		gm.gain_plays(1)


func _on_restock_pressed() -> void:
	pass # Replace with function body.


func _on_mid_hole_multiplier_pressed() -> void:
	var button = $SidePanel/ShopColumns/ShopRow/MidHoleMultiplier
	
	var price: int = 20
	var new_price: int = 50
	var amount_to_upgrade_by: int = 1
	
	match mid_hole_upgrades:
		1: 
			price = 50 
			new_price = 80
			amount_to_upgrade_by = 1
		2: 
			price = 80
			new_price = 120
			amount_to_upgrade_by = 1
		3: 
			price = 120
			new_price = 0
			amount_to_upgrade_by = 1
		
	var spendable = gm.spend_points(price)
	if spendable == true:
		$"../../../MediumTimes2Hole".point_modifier += amount_to_upgrade_by
		$"../../../MediumTimes2Hole".update_mult_label()
		
		$"../../../MediumTimes2Hole2".point_modifier += amount_to_upgrade_by
		$"../../../MediumTimes2Hole2".update_mult_label()
		
		mid_hole_upgrades += 1
		if new_price == 0:
			button.text = "Mid Hole Multiplier Max"
			button.disabled = true
		else:
			button.text = "Mid Hole Multiplier + 1\nCost: " + str(new_price)


func _on_small_hole_multiplier_pressed() -> void:
	var button = $SidePanel/ShopColumns/ShopRow/SmallHoleMultiplier
	
	var price: int = 20
	var new_price: int = 50
	var amount_to_upgrade_by: int = 1
	
	match small_hole_upgrades:
		1: 
			price = 50 
			new_price = 80
			amount_to_upgrade_by = 1
		2: 
			price = 80
			new_price = 120
			amount_to_upgrade_by = 1
		3: 
			price = 120
			new_price = 0
			amount_to_upgrade_by = 1
		
	var spendable = gm.spend_points(price)
	if spendable == true:
		$"../../../SmallTimes3Hole".point_modifier += amount_to_upgrade_by
		$"../../../SmallTimes3Hole".update_mult_label()
		
		
		small_hole_upgrades += 1
		if new_price == 0:
			button.text = "Small Hole Multiplier Max"
			button.disabled = true
		else:
			button.text = "Small Hole Multiplier + 1\nCost: " + str(new_price)
