extends Control

export(int) var level

func _ready() -> void:
	$Label.text = "Level " + str(level)
	
	var time = Scores.get_time_from_level(level)
	if time == 0:
		$"High Score".text = "--:--"
	else:
		$"High Score".text = Scores.time_to_string(time)
	
	
	var coins = $"Coin Container".get_children()
	for i in range(3):
		if i >= Scores.get_coins_from_level(level):
			coins[i].modulate = Color(909090)

	if !Scores.is_level_enabled(level):
		$Play.disabled = true

func _on_Play_pressed() -> void:
	get_tree().change_scene(str("res://Levels/Level", level, ".tscn"))
