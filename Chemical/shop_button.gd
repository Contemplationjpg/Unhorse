class_name ShopButton
extends Button

@export var item_name : String = "Default"
@export var increase_amount : String = "+1 Item"
@export var cost : int = 100


func _ready() -> void:
	update_shop_button_text()

func set_shop_button_values(new_name : String, new_inc_amt : String, new_cost : int):
	item_name = new_name
	increase_amount = new_inc_amt
	cost = new_cost
	update_shop_button_text()

func update_shop_button_text():
	var res : String = item_name #create item name text
	res += str("\n" +increase_amount) #create increase amount text
	res += str("\nCOST: " + str(cost)) #create cost text
	text = res #set text as our new listing

