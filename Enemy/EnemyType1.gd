extends KinematicBody2D

var RUN_SPEED = 400
var RUN_ACCEL = 0.2
var RUN_DECEL = 0.2
var TURN_ACCEL = 0.2

var KNOCKBACK_SPEED = 1000
var PAUSE_TIME = 1

var velocity = Vector2.ZERO
var dir = Vector2.ZERO
var player = null

export var moving = true
var timer;

func _ready() -> void:
	$ColorRect.modulate = Color("3D3D3D")
	$ColorRect2.modulate = Color.lightcoral

func _physics_process(delta):
	choose_direction()
	if player and moving:
		move_towards_player()
	else:
		velocity = lerp(velocity, Vector2.ZERO, RUN_DECEL)
	velocity = move_and_slide(velocity)
	
func move_towards_player():
	dir = lerp(dir, position.direction_to(player.position), TURN_ACCEL)
	velocity = lerp(velocity, RUN_SPEED * dir, RUN_ACCEL)
	
func choose_direction():
	if velocity.x > 0:
		$Sprite.set_flip_h(false)
	else:
		$Sprite.set_flip_h(true)


func damage():
	print("damaged")
	$CollisionShape2D.disabled = true
	self.queue_free()

func attack(direction: float):
	print("attacking!")
	velocity.x = cos(direction) * KNOCKBACK_SPEED;
	velocity.y = sin(direction) * KNOCKBACK_SPEED;

	moving = false
	$Timer.start(PAUSE_TIME)
	

	
	
	

func _on_Detection_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		player = body


func _on_Timer_timeout() -> void:
	$Timer.stop()
	moving = true
