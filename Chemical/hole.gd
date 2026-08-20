class_name Hole
extends Node2D


@export var point_modifier : float = 1
@export var mult_label : RichTextLabel
@export var sprite : AnimatedSprite2D


@onready var area : Area2D = $Area2D
@onready var gm : ChemicalGameManager = ChemicalGameManager

var loot_in_range : Array[Loot] = []

func _ready() -> void:
	gm.update_holes.connect(update_mult_label)
	area.body_entered.connect(on_area_enter)
	area.body_exited.connect(on_area_exit)
	item_rect_changed.connect(update_mult_label)
	update_mult_label()
	var start_frame = randi_range(0,3)
	sprite.frame = start_frame
	sprite.play()


func _physics_process(delta: float) -> void:
	score_all_loot_in_range() #attempts to score all loot within range every frame


func score_all_loot_in_range():
	for i in range(loot_in_range.size() - 1, -1, -1): #iterates through list using range(start, stop, step)
		#start_score() and hole_start_score() both start scoring process but hole_start_score() can pass a point modifier
		if loot_in_range[i].hole_start_score(point_modifier):
			loot_in_range.remove_at(i)

#connected to item_rect_changed so that it moves with the hole if that somehow ever happens????
func update_mult_label():
	mult_label.visible = true
	mult_label.text = str("x" + str(point_modifier))
	#label position is top left and center justified
	var x = global_position.x - mult_label.size.x/2 #x position is moved half of size.x left
	var y = global_position.y - mult_label.size.y/2 #y position is moves half of size.y up
	mult_label.position = Vector2(x,y)


func on_area_enter(body : Node2D):
	var new_loot = body as Loot
	if new_loot:
		if loot_in_range.find(new_loot) == -1:
			loot_in_range.append(new_loot)
	
func on_area_exit(body : Node2D):
	var new_loot = body as Loot
	if new_loot:
		var loot_index = loot_in_range.find(new_loot)
		if loot_index != -1:
			loot_in_range.remove_at(loot_index)
