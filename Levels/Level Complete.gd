extends Area2D




func _on_Level_Complete_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		get_tree().change_scene("res://Levels/Level2.tscn")
