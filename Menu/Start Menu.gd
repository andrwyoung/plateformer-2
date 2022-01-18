extends Node2D

func _on_Start_pressed() -> void:
	get_tree().change_scene("res://Levels/Level1.tscn")


func _on_Level_Select_pressed() -> void:
	get_tree().change_scene("res://Menu/Level Select.tscn")


func _on_Quit_pressed() -> void:
	get_tree().quit()
