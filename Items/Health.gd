extends Area2D


func disable():
	$CollisionShape2D.set_deferred("disabled", true)
	$ColorRect.visible = false

func enable():
	$CollisionShape2D.set_deferred("disabled", false)
	$ColorRect.visible = true

func _on_Health_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		body.restore_health()
		disable()
