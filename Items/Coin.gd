extends Area2D



func _on_Coin_body_entered(body: Node) -> void:
	print("coin!")
	if body.is_in_group("Player"):
		body.collect_coin()
		queue_free()
