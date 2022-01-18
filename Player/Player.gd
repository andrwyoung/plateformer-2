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

const KNOCKBACK_TIME = 1
const KNOCKBACK_SPEED = 600

const NORMAL_COLOR = Color("cbddff")
const KNOCKBACK_COLOR = Color.lightcoral
const DASH_COLOR = Color.cornflower
const DASH_DISABLED_COLOR = Color.white

export var camera_cutoff = 800

var velocity = Vector2.ZERO
var dir = Vector2.ZERO
var respawn_point = Vector2() 
var invulnerable = false

var coyote_timer = 0.0
var ground_timer = 0.0
var able_to_dash = true # dash refresh when touching floor
var skip_dash_cooldown = false

var coins = 0
signal coin_gotten(coins)

const MAX_HEALTH = 3
var health = MAX_HEALTH
var damage_taken = 0
signal health_changed(health)

const Indicator = preload("res://Indicator.tscn")

enum sm {
	MOVING,
	DASHING,
	NO_MOVE
}
var state = sm.MOVING


func _ready() -> void:
	$Camera2D.limit_bottom = camera_cutoff
	respawn_point = position # spawn point is where you start out

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
				enable_powerups();
				coyote_timer = COYOTE_TIME
				if $DashCoolDownTimer.is_stopped():
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
						
			if able_to_dash and modulate == DASH_DISABLED_COLOR:
				tween_to_color(NORMAL_COLOR)
		sm.DASHING:
			process_dashing();
		sm.NO_MOVE:
			pass
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
	
func is_directly_above(other_position: Vector2) -> bool:
	var within_x_axis = abs(other_position.x - self.position.x) <= $ColorRect.rect_size.x / 2
	var within_y_axis = self.position.y < other_position.y
	return within_x_axis and within_y_axis

#func change_direction(direction: int):
#	if direction == -1:
#		$Sprite.set_flip_h(true)
#	elif direction == 1:
#		$Sprite.set_flip_h(false)


# GAME FUNCTIONS
func damage_player():
	print("ouch!!")
	health -= 1
	damage_taken += 1
	emit_signal("health_changed", health)
	if health <= 0:
		game_over();
	get_tree().call_group("Health", "enable")

func restore_health():
	health = MAX_HEALTH
	emit_signal("health_changed", health)

func damage_and_respawn():
	damage_player()
	enable_powerups()
	position = respawn_point
	velocity = Vector2.ZERO
	state = sm.NO_MOVE
	
	able_to_dash = true
	$KnockBackTimer.start(KNOCKBACK_TIME)
	$DashCoolDownTimer.stop()
	
	$Tween.stop_all()
	$DashTimer.start(DASH_TIME)
	$ColorRect.modulate = KNOCKBACK_COLOR

func game_over():
	print("game over!")
	get_tree().reload_current_scene()

func apply_gravity(delta: float) -> void:
	velocity.y = min(velocity.y + GRAVITY * delta, MAX_FALL)
	
func jump() -> void:
	coyote_timer = 0
	velocity.y = -JUMP_SPEED
	
func enable_powerups() -> void:
	get_tree().call_group("Powerups", "enable")

func set_spawn_point(collision) -> void:
	var tilemap = collision.collider
	var cell = tilemap.world_to_map(collision.position)

	if collision.normal.x == 1: cell += Vector2(-1, -1)
	if collision.normal.y == 1: cell += Vector2(0, -1)
	if collision.normal.y == -1: cell += Vector2(-1, 0)
		
	var tile_center_pos = tilemap.map_to_world(cell) + tilemap.cell_size / 2
	respawn_point = tile_center_pos
	respawn_point.y -= tilemap.cell_size.y / 2 + $ColorRect.rect_size.y / 2
#			print("player is at: ", position, " and cell is: ", tile_center_pos)
#	if tilemap.get_cellv(cell) != -1:
#		var IndicatorInstance = Indicator.instance()
#		IndicatorInstance.position = respawn_point
#		get_owner().add_child(IndicatorInstance)

func complete_level(curr_level) -> void:
	$GUI.queue_free()
	
	var next_level = str("res://Levels/Level", curr_level + 1, ".tscn")
	
	# load finish screen
	var finish_ui = preload("res://GUI/Level Complete UI.tscn").instance()
	finish_ui.init(next_level, $GUI.get_elapsed_time(), damage_taken, coins)
	get_parent().add_child(finish_ui)
	
	# update scores
	Scores.update_score(curr_level, coins, $GUI.get_elapsed_time())
	
	# get player off the screen
	$ColorRect.visible = false
	velocity = Vector2.ZERO
	state = sm.NO_MOVE

# COLLISIONS
func process_collisions() -> void:
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		var collider = collision.collider
		if collider.is_in_group("Enemy"):
			if state == sm.DASHING:
				collider.damage()
			else:
				var angle = calculate_angle_from_self(collider.position)
				collider.attack(angle)
				if state != sm.NO_MOVE:
					init_knockback(angle)
					damage_player()
		if is_on_floor() and collider.is_in_group("Tile") and is_directly_above(collision.position):
			set_spawn_point(collision)
		if collider.is_in_group("Lava") and state != sm.NO_MOVE:
			damage_and_respawn()



# ANIMATION
func tween_to_color(color):
	$Tween.interpolate_property($ColorRect, "modulate", $ColorRect.modulate, color, DASH_TWEEN_LENGTH, Tween.TRANS_LINEAR)
	$Tween.start()
	
	
#DASHING
func init_dash() -> void:
	print("dashing")
	coyote_timer = 0  # prevent initial jump
	able_to_dash = false
	state = sm.DASHING
	velocity = Vector2.ZERO
	
	$ColorRect.modulate = DASH_COLOR
	$Tween.stop_all()
	$DashTimer.start(DASH_TIME)

func process_dashing() -> void:
	velocity = lerp(velocity, DASH_SPEED * dir.normalized(), DASH_ACCEL)



# KNOCKBACK
func init_knockback(direction: float):
	print("direction: ", direction, " cos: ", cos(direction), " sin: ", sin(direction))
	state = sm.NO_MOVE
	$KnockBackTimer.start(KNOCKBACK_TIME)
	velocity.x = -cos(direction) * KNOCKBACK_SPEED;
	velocity.y = -sin(direction) * KNOCKBACK_SPEED;
	print("velocity: ", velocity)
	
	$Tween.stop_all()
	$DashTimer.start(DASH_TIME)
	$ColorRect.modulate = KNOCKBACK_COLOR

# SIGNALS
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			if able_to_dash:
				dir = get_local_mouse_position().normalized()
				init_dash()
	if event.is_action("restart"):
		get_tree().reload_current_scene()
	if event.is_action("pause"):
		var pause_menu = preload("res://GUI/Paused.tscn").instance()
		get_parent().add_child(pause_menu)
		get_tree().paused = true

func powerup():
	able_to_dash = true
	skip_dash_cooldown = true
	$DashCoolDownTimer.stop()
	
func collect_coin():
	coins += 1
	$SFX/Coin.play()
	emit_signal("coin_gotten", coins)

func _on_VisibilityNotifier2D_screen_exited() -> void:
	print(position)
	damage_and_respawn()


func _on_DashTimer_timeout() -> void:
	$DashTimer.stop()
	tween_to_color(DASH_DISABLED_COLOR)

	state = sm.MOVING
	if !skip_dash_cooldown:
		$DashCoolDownTimer.start(DASH_COOLDOWN)

func _on_DashCoolDownTimer_timeout() -> void:
	$DashCoolDownTimer.stop()


func _on_KnockBackTimer_timeout() -> void:
	tween_to_color(NORMAL_COLOR);
	$KnockBackTimer.stop()
	
	state = sm.MOVING
