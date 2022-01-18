extends Node

var levels = []

class Level:
	var completed = false
	var time = 0
	var coins = 0

func _ready() -> void:
	for i in range(5):
		levels.append(Level.new())

func get_time_from_level(level):
	return levels[level - 1].time

func get_coins_from_level(level):
	return levels[level - 1].coins
	
func is_level_completed(level):
	return levels[level - 1].completed


func is_level_enabled(level):
	if level == 1:
		return true
	else:
		# level is enabled if itself or previous level has been completed
		return levels[level - 2].completed || levels[level - 1].completed
	
	
func update_score(level_to_change, new_coins, new_time):
	var level = levels[level_to_change - 1]
	level.completed = true
	level.coins = new_coins
	level.time = new_time

func time_to_string(time) -> String: 
		var minutes = time / 60
		var seconds = time % 60
		return "%02d : %02d" % [minutes, seconds]
