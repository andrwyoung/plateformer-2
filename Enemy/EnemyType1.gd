extends KinematicBody2D

var RUN_SPEED = 700
var RUN_ACCEL = 0.3
var TURN_ACCEL = 0.2

var velocity = Vector2.ZERO
var dir = Vector2.ZERO
var player = null


func _physics_process(delta):
	velocity = Vector2.ZERO
	if player:
		dir = lerp(dir, position.direction_to(player.position), TURN_ACCEL)
		velocity = lerp(velocity, RUN_SPEED * dir, RUN_ACCEL)
	velocity = move_and_slide(velocity)
	
	
	
func damage():
	print("damaged")
	$CollisionShape2D.disabled = true
	self.queue_free()

func attack():
	velocity = Vector2.ZERO
	

func _on_Detection_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		player = body
