extends Area2D

export(int) var curr_level;

func _on_Level_Complete_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		body.complete_level(curr_level)
