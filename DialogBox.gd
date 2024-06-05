extends NinePatchRect

signal text_finished


const MAX_CHAR = 51
const MAX_ROW = 4
const SPEED = .005
var text_queue = []
var await_input = false
var autoplay = false

# Text is a string argument
func play_text(text, auto=false):
	
	autoplay = auto
	text = text.split(" ")
	var line = ""
	var c = 0
	var word_idx = 0
	while word_idx < text.size():
		text[word_idx] = text[word_idx].strip_edges() + " "
		if !((c + text[word_idx].length()) > MAX_CHAR):
			c += text[word_idx].length()
			line += (text[word_idx])
			word_idx += 1
		else:
			text_queue.append(line)
			line = ""
			c = 0
	if line:
		text_queue.append(line)
		
	$Label.text=queue_up()
	$AnimationPlayer.play("show_text")
	visible=true
	if autoplay:
		$Timer.wait_time = .5
		$Timer.start()
		
	
# Return next paragraph 
func queue_up():
	
	var next_text = ""
	$Label.visible_ratio = 0
	if text_queue.size() >= 3:
		var this_slice = text_queue.slice(0, MAX_ROW)
		for t in this_slice:
			next_text += t + "\n"
		for i in range(MAX_ROW):
			text_queue.pop_front()
			
	else:
		for t in text_queue:
			next_text += t + "\n"
		text_queue = []
		
	# Set animation speed
	var anim = $AnimationPlayer.get_animation("show_text")
	anim.length = SPEED*next_text.length()
	anim.track_set_key_time(0, 1, anim.length)
	return next_text

func play_next():
	$AnimationPlayer.seek(0)
	var next_text = queue_up()
	if next_text:			
		$Label.text = next_text
		$AnimationPlayer.play("show_text")
		if autoplay:
			$Timer.start()
		
	else:
		Input.set_custom_mouse_cursor(Globals.default_cursor)
		call_deferred("emit_signal", "text_finished")
	
	await_input = false
	

func force_stop():
	$AnimationPlayer.stop()
	await_input = false
	visible = false

func _on_animation_player_animation_finished(anim_name):
	await_input = true

func _on_gui_input(event):
	if event.is_action_pressed("click") && await_input:
		play_next()
		
func _on_timer_timeout():
	play_next()

func _on_mouse_entered():
	Input.set_custom_mouse_cursor(Globals.dialog_cursor)

func _on_mouse_exited():
	Input.set_custom_mouse_cursor(Globals.default_cursor)

