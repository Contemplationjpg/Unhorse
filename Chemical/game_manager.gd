extends Node

signal on_gain_points(points_gained : int)
signal on_gain_plays(plays_gained : int)
signal on_gain_spins(spins_gained : int)

signal on_spend_points(points_spent : int)
signal on_spend_plays(plays_spent : int)
signal on_spend_spins(spins_spent : int)


var points : int = 500
var plays : int = 3
var spins : int = 0

func gain_points(p : int):
	points += p
	on_gain_points.emit(p)

func gain_plays(p : int):
	plays += p
	on_gain_plays.emit(p)

func gain_spins(s : int):
	spins += s
	on_gain_spins.emit(s)
	

func spend_points(p : int) -> bool:
	if p < points:
		return false
	points -= p
	on_spend_points.emit(p)
	return true

func spend_plays(p : int) -> bool:
	if p < plays:
		return false
	plays -= p
	on_spend_plays.emit(p)
	return true

func spend_spins(s : int) -> bool:
	if s < spins:
		return false
	spins -= s
	on_spend_spins.emit(s)
	return true
