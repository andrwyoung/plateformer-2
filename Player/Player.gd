extends KinematicBody2D
class_name Player

const UP = Vector2(0, -1)
const GRAVITY = 2000.0
const MAX_FALL = 600.0
const RUN_SPEED = 350.0
const RUN_ACCEL = 0.4
const RUN_DECEL = 0.6
const AIR_ACCEL = 0.3
const AIR_DECEL = 0.1

const DASH_SPEED = 600.0
const DASH_ACCEL = 0.4
const DASH_TIME = 0.2
const DASH_COOLDOWN = 0.3

const JUMP_SPEED = 700.0
const JUMP_CUT = 0.5 # how much to cut gravity after jump
const COYOTE_TIME = 0.1
const GROUND_TIME = 0.1

const KNOCKBACK_TIME = 0.3

export var camera_cutoff = 800

var velocity = Vector2.ZERO
var dir = Vector2.ZERO
var spawn_point = Vector2()
var face_direction = 1
var able_to_move = true
var invulnerable = false

var coyote_timer = 0.0
var ground_timer = 0.0
var knockback_timer = 0.0

var dash_timer = -DASH_COOLDOWN
var able_to_dash = true # dash refresh when touching floor
var is_dashing = false


func _ready() -> void:
	$Camera2D.limit_bottom = camera_cutoff
	spawn_point = position # spawn point is where you start out

func _physics_process(delta: float) -> void:
	ground_timer = max(ground_timer - delta, 0)
	dash_timer = max(dash_timer - delta, -DASH_COOLDOWN)
	knockback_timer = max(knockback_timer - delta, 0)
	
	process_knockback();
	
	if !is_dashing:
		dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		
		# X AXIS
		if dir.x != 0:
			face_direction = dir.x
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
			coyote_timer = COYOTE_TIME
			able_to_dash = true
			
			if ground_timer > 0:
				print("ground time!")
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
					print("cutting jump")
					velocity.y *= JUMP_CUT

	
	process_dashing();
	
	velocity = move_and_slide(velocity, UP)
	
	process_collisions();



func apply_gravity(delta: float) -> void:
	velocity.y = min(velocity.y + GRAVITY * delta, MAX_FALL)
	
func jump() -> void:
	coyote_timer = 0
	velocity.y = -JUMP_SPEED
	
	
	
	
#DASHING
func init_dash() -> void:
	print("dashing")
	coyote_timer = 0  # prevent initial jump
	able_to_move = false
	able_to_dash = false
	is_dashing = true
	velocity = Vector2.ZERO
	dash_timer = DASH_TIME
	$ColorRect.color = Color(255, 0, 0)

func process_dashing() -> void:
	if is_dashing:
		if dash_timer < 0: 
			is_dashing = false
			able_to_move = true
		else:
			velocity = lerp(velocity, DASH_SPEED * dir.normalized(), DASH_ACCEL)
	else:
		$ColorRect.color = Color(255, 255, 255)


# COLLISIONS
func process_collisions() -> void:
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.is_in_group("Enemy") and !invulnerable:
			if is_dashing:
				collision.collider.damage()
			else:
				collision.collider.attack()
				init_knockback(collision.get_angle());

func is_damaged():
	print("ouch!!")

func init_knockback(direction: float):
	able_to_move = false;
	invulnerable = true
	knockback_timer = KNOCKBACK_TIME
	velocity.x = cos(direction);
	velocity.y = sin(-direction);

func process_knockback():
	if knockback_timer <= 0:
		able_to_move = true;
		invulnerable = false;
	
	

# SIGNALS
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
#		print("timer: ", dash_timer, " able to dash: ", able_to_dash, " is dashing: ", is_dashing);
		if event.pressed:
			if able_to_dash and dash_timer <= -DASH_COOLDOWN:
				dir = get_local_mouse_position().normalized()
				init_dash()
	if event.is_action("restart"):
		get_tree().reload_current_scene()

func _on_VisibilityNotifier2D_screen_exited() -> void:
	print("player can't be seen. respawning")
	print(position)
	position = spawn_point
