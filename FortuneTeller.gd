extends Node2D

signal display_text
signal carry_over
signal carry_back
signal mouse_entered
signal mouse_exited

var fortune_told = false
var fortunescript = load("res://Fortune.gd")
var fortune
var pre_dialog = ["I am going to see your future now..."]
var game_states

func _click_ball(viewport, event: InputEvent, shape):
	if event.is_action_pressed("click") && !fortune_told:
		start_fortune()

# Start process by playing crystal ball animation
func start_fortune():
	$CrystalBall.play("start")
	emit_signal("display_text", pre_dialog[0])

# Create fortune from script, emit signal to display text on canvas
func tell_fortune():
	var fortune_teller = fortunescript.new()
	fortune = Array(fortune_teller.create_fortune().split("\n"))
	while "" in fortune:
		fortune.erase("")
	emit_signal("display_text", fortune.pop_front(), true)
	fortune_told=true

# Continue fortune dialog
func dialog_finished():
	if fortune_told:
		var next_piece = fortune.pop_front()
		if next_piece && fortune:
			emit_signal("display_text", next_piece, true)
		elif next_piece && (fortune==[]):
			emit_signal("display_text", next_piece, false)
			$CrystalBall.stop()
			$CrystalBall.play_backwards("start")
			


# Start Crystal Ball loop
func _on_crystal_ball_animation_finished():
	if $CrystalBall.animation == "start" and !fortune_told:
		$CrystalBall.play("loop")
		tell_fortune()
	# Reset the program so the fortune can be called again
	elif $CrystalBall.animation == "start" and fortune_told:
		# Reset fortune_told
		fortune_told=false
