extends CanvasLayer

func _on_Continue_pressed() -> void:
	get_tree().paused = false
	self.queue_free()
	
func _on_Try_Again_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	
func _on_Level_Select_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene("res://Menu/Level Select.tscn")
