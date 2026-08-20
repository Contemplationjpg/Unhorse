class_name ChanceLoot
extends Loot

@export_category("Chance Loot Settings")
@export var base_spin_value : int = 1
@export var gets_multiplied_by_hole_point_modifier : bool = true

func on_score_non_destroy():
	super()
	var spin_reward : int
	if gets_multiplied_by_hole_point_modifier:
		spin_reward = int(base_spin_value*hole_point_modifier)
	else:
		spin_reward = base_spin_value

	gm.gain_spins(spin_reward)
