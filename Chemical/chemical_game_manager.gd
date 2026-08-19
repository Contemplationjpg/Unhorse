extends Node

#signals for whenever any change to stats happens in case we want to add effects that pay attention to this, so please use the correct resource gain/spend functions
signal on_gain_points(points_gained : int)
signal on_gain_plays(plays_gained : int)
signal on_gain_spins(spins_gained : int)

signal on_spend_points(points_spent : int)
signal on_spend_plays(plays_spent : int)
signal on_spend_spins(spins_spent : int)

signal on_any_update() #this "on_any_update" signal is intended for things like updating ui but tbh you can go wild with this if you want

signal on_loot_scored(position : Vector2, amount : int)


#resources--------------------------------
var points : int = 500
var plays : int = 3
var spins : int = 0


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
