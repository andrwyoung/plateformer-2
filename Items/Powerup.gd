extends Area2D



func _on_Enemy1_body_entered(body: Node) -> void:
	print("entered!")
	body.able_to_dash = true
	self.queue_free()
