extends CanvasLayer

var hearts
var coins 

var time_start
var time_now

func _ready() -> void:
	hearts = $HBoxContainer2.get_children()
	coins = $HBoxContainer3.get_children()
	
	time_start = OS.get_unix_time()
	set_process(true)


func _process(delta: float) -> void:
	time_now = OS.get_unix_time()
	var elapsed = time_now - time_start
	var minutes = elapsed / 60
	var seconds = elapsed % 60
	var str_elapsed = "%02d : %02d" % [minutes, seconds]
	
	$RichTextLabel.set_text(str_elapsed)

func _on_Player_health_changed(health) -> void:
	for heart in hearts:
		heart.visible = false
	for i in range(health):
		hearts[i].visible = true


func _on_Player_coin_gotten(num_coins) -> void:
	for i in range(num_coins):
		coins[i].visible = true
