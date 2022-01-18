extends Area2D

func _ready() -> void:
	$Animation.play("UpDown")

func _on_Coin_body_entered(body: Node) -> void:
	print("coin!")
	if body.is_in_group("Player"):
		body.collect_coin()
		queue_free()
