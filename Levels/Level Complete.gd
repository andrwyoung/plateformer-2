extends Area2D

export var level = "res://Levels/Test.tscn"


func _on_Level_Complete_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		get_tree().change_scene(level)
