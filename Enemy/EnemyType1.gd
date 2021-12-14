extends KinematicBody2D

var RUN_SPEED = 700
var RUN_ACCEL = 0.3
var TURN_ACCEL = 0.2

var PAUSE_TIME = 1

var velocity = Vector2.ZERO
var dir = Vector2.ZERO
var player = null

export var moving = true
var timer;

func _physics_process(delta):
	velocity = Vector2.ZERO
	if player and moving:
		move_towards_player()
	velocity = move_and_slide(velocity)
	
func move_towards_player():
	dir = lerp(dir, position.direction_to(player.position), TURN_ACCEL)
	velocity = lerp(velocity, RUN_SPEED * dir, RUN_ACCEL)
	
	

func damage():
	print("damaged")
	$CollisionShape2D.disabled = true
	self.queue_free()

func attack(direction: float):
	print("attcking!")
	velocity = Vector2.ZERO
	
	moving = false
	yield(get_tree().create_timer(1), "timeout")
	moving = true
	
	
	

func _on_Detection_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		player = body

