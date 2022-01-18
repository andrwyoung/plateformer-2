extends CanvasLayer

var hearts
var coins 

var elapsed = 0.0

func _ready() -> void:
	hearts = $HBoxContainer2.get_children()
	coins = $HBoxContainer3.get_children()

	set_process(true)

func get_elapsed_time():
	return int(round(elapsed))

func _process(delta: float) -> void:
	elapsed += delta

	$RichTextLabel.set_text(Scores.time_to_string(int(round(elapsed))))

func _on_Player_health_changed(health) -> void:
	for heart in hearts:
		heart.visible = false
	for i in range(health):
		hearts[i].visible = true


func _on_Player_coin_gotten(num_coins) -> void:
	for i in range(num_coins):
		coins[i].visible = true
