extends CanvasLayer

var next_level


func init(level, time, damage, num_coins) -> void:
	next_level = level
	if next_level == "res://Levels/Level6.tscn":
		$"HBoxContainer/Next Level".queue_free()
	$Label.text = Scores.time_to_string(time)
	
	var coins = $"Coin Container".get_children()
	for i in range(3):
		if i >= num_coins:
			coins[i].modulate = Color(909090)

func _on_Next_Level_pressed() -> void:
	get_tree().change_scene(next_level)

func _on_Try_Again_pressed() -> void:
	get_tree().reload_current_scene()


func _on_Level_Select_pressed() -> void:
	get_tree().change_scene("res://Menu/Level Select.tscn")
