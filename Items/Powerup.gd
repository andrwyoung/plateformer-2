extends Area2D



func _ready() -> void:
	self.modulate = Color.cornflower

func disable():
	$CollisionShape2D.set_deferred("disabled", true)
	$ColorRect.visible = false

func enable():
	$CollisionShape2D.set_deferred("disabled", false)
	$ColorRect.visible = true

func _on_Enemy1_body_entered(body: Node) -> void:
	print("powerup!")
	if body.is_in_group("Player"):
		body.powerup()
		disable()
