extends ParallaxBackground

class_name Scenes


signal display_text
signal first_interaction
signal image_ready
signal terminate_dialog

signal enter_portal

var game_saved=true
# script for tracking points/scores
var game_states
# Index of this scene among settings
var setting_index:int

# Called when the node enters the scene tree for the first time.
func _ready():# Connect to interaction signals
	if !get_node("Control").gui_input.is_connected(_on_control_gui_input):
		get_node("Control").gui_input.connect(_on_control_gui_input)
	
func dialog_finished():
	return

# Highlight Mouse
func _on_button_mouse_entered():
	Input.set_custom_mouse_cursor(Globals.select_cursor)

#Undo highlight mouse
func _on_button_mouse_exited():
	Input.set_custom_mouse_cursor(Globals.default_cursor)

func _display_text(text, keep_vis=false, autoplay=false):
	emit_signal("display_text", text, keep_vis,autoplay)


	
		
func take_screenshot():
	visible = true
	await RenderingServer.frame_post_draw
	emit_signal("image_ready")
	return


# Emitted when player clicks on this scene first time
func _on_control_gui_input(event):
	if event.is_action_pressed("click") and game_saved:
		emit_signal("first_interaction")
		game_saved = false
		
		


func _enter_portal():
	emit_signal("enter_portal", setting_index)
	
