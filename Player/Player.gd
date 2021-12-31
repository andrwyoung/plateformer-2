extends KinematicBody2D
class_name Player

const UP = Vector2(0, -1)
const GRAVITY = 2500.0
const MAX_FALL = 1200.0
const RUN_SPEED = 500.0
const RUN_ACCEL = 0.4
const RUN_DECEL = 0.6
const AIR_ACCEL = 0.3
const AIR_DECEL = 0.1

const DASH_SPEED = 1400.0
const DASH_ACCEL = .95
const DASH_TIME = 0.2
const DASH_COOLDOWN = 0.3
const DASH_TWEEN_LENGTH = 0.1

const JUMP_SPEED = 900.0
const JUMP_CUT = 0.5 # how much to cut gravity after jump
const COYOTE_TIME = 0.1
const GROUND_TIME = 0.1

const KNOCKBACK_TIME = 0.3
const KNOCKBACK_SPEED = 600

export var camera_cutoff = 800

var velocity = Vector2.ZERO
var dir = Vector2.ZERO
var spawn_point = Vector2()
var invulnerable = false

var coyote_timer = 0.0
var ground_timer = 0.0
var able_to_dash = true # dash refresh when touching floor
var skip_dash_cooldown = false

var coins = 0
var health = 3



enum sm {
	MOVING,
	DASHING,
	KNOCKED_BACK
}
var state = sm.MOVING


func _ready() -> void:
	$Camera2D.limit_bottom = camera_cutoff
	spawn_point = position # spawn point is where you start out

func _physics_process(delta: float) -> void:
	ground_timer = max(ground_timer - delta, 0)
	
	match state:
		sm.MOVING:
			dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
			dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
			
			# X AXIS
			if dir.x != 0:
				if is_on_floor():
					velocity.x = lerp(velocity.x, RUN_SPEED * dir.x, RUN_ACCEL)
				else:
					velocity.x = lerp(velocity.x, RUN_SPEED * dir.x, AIR_ACCEL)
			else:

				if is_on_floor():
					velocity.x = lerp(velocity.x, 0, RUN_DECEL)
				else:
					velocity.x = lerp(velocity.x, 0, AIR_DECEL)

			# Y AXIS
			apply_gravity(delta)
			
			if is_on_floor():
				get_tree().call_group("Powerups", "enable")
				coyote_timer = COYOTE_TIME
				able_to_dash = true
				
				
				if ground_timer > 0:
					print("ground time")
					jump()
					ground_timer = 0
				elif Input.is_action_just_pressed("jump"):
					jump()
			else:
				coyote_timer = max(coyote_timer - delta, 0)
				if Input.is_action_just_pressed("jump"):
					if coyote_timer > 0:
						print("coyote jump")
						jump()
					else: 
						ground_timer = GROUND_TIME
				
				if velocity.y < 0:
					if Input.is_action_just_released("jump"):
						velocity.y *= JUMP_CUT
		sm.DASHING:
			process_dashing();
		sm.KNOCKED_BACK:
			process_knockback();
		_:
			print("ERROR: unknown state")
	
	
	velocity = move_and_slide(velocity, UP)
	process_collisions();


#HELPER FUNCTIONS
func calculate_angle_from_self(other_position: Vector2) -> float:
	var dy = other_position.y - self.position.y
	var dx = other_position.x - self.position.x
	var theta = PI/2
	if dx != 0:
		theta = atan(dy / dx)
	if dx < 0:
		theta += PI
	return theta

#func change_direction(direction: int):
#	if direction == -1:
#		$Sprite.set_flip_h(true)
#	elif direction == 1:
#		$Sprite.set_flip_h(false)

func apply_gravity(delta: float) -> void:
	velocity.y = min(velocity.y + GRAVITY * delta, MAX_FALL)
	
func jump() -> void:
	coyote_timer = 0
	velocity.y = -JUMP_SPEED
	
	
	
	
#DASHING
func init_dash() -> void:
	print("dashing")
	coyote_timer = 0  # prevent initial jump
	able_to_dash = false
	state = sm.DASHING
	velocity = Vector2.ZERO
	
	$ColorRect.modulate = Color.cornflower
	$DashTimer.start(DASH_TIME)

func process_dashing() -> void:
	velocity = lerp(velocity, DASH_SPEED * dir.normalized(), DASH_ACCEL)




# COLLISIONS
func process_collisions() -> void:
	for i in get_slide_count():
		var collider = get_slide_collision(i).collider
		if collider.is_in_group("Enemy"):
			if state == sm.DASHING:
#				able_to_dash = true
				collider.damage()
			else:
				var angle = calculate_angle_from_self(collider.position)
				collider.attack(angle)
				if state != sm.KNOCKED_BACK:
					init_knockback(angle)
					damage_player()

# GAME FUNCTIONS
func damage_player():
	print("ouch!!")
	health -= 1
	if health <= 0:
		game_over();
	
func game_over():
	print("game over!")
	get_tree().reload_current_scene()




# KNOCKBACK
func init_knockback(direction: float):
	print("direction: ", direction, " cos: ", cos(direction), " sin: ", sin(direction))
	state = sm.KNOCKED_BACK
	$KnockBackTimer.start(KNOCKBACK_TIME)
	velocity.x = -cos(direction) * KNOCKBACK_SPEED;
	velocity.y = -sin(direction) * KNOCKBACK_SPEED;
	print("velocity: ", velocity)
	
	$ColorRect.modulate = Color.lightcoral

func process_knockback():
	pass



# ANIMATION
func tween_back_to_normal_color():
	$Tween.interpolate_property($ColorRect, "modulate", $ColorRect.modulate, Color.white, DASH_TWEEN_LENGTH, Tween.TRANS_LINEAR)
	$Tween.start()



# SIGNALS
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
#		print(able to dash: ", able_to_dash, " state: ", state);
		if event.pressed:
			if able_to_dash and $DashCoolDownTimer.is_stopped():
				dir = get_local_mouse_position().normalized()
				init_dash()
	if event.is_action("restart"):
		get_tree().reload_current_scene()

func powerup():
	able_to_dash = true
	skip_dash_cooldown = true
	$DashCoolDownTimer.stop()
	
func collect_coin():
	coins += 1

func _on_VisibilityNotifier2D_screen_exited() -> void:
	print(position)
	damage_player()
	position = spawn_point


func _on_DashTimer_timeout() -> void:
	$DashTimer.stop()
	tween_back_to_normal_color();

	state = sm.MOVING
	if !skip_dash_cooldown:
		$DashCoolDownTimer.start(DASH_COOLDOWN)

func _on_DashCoolDownTimer_timeout() -> void:
	$DashCoolDownTimer.stop()


func _on_KnockBackTimer_timeout() -> void:
	tween_back_to_normal_color();
	$KnockBackTimer.stop()
	
	state = sm.MOVING
