extends Area2D

func _ready() -> void:
	self.modulate = Color.aquamarine

func _on_Checkpoint_body_entered(body: Node) -> void:
	print("checkpoint!")
	if body.is_in_group("Player"):
		self.modulate = Color.white
		body.spawn_point = self.position
