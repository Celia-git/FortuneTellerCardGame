extends Scenes

class_name InteriorScenes


signal update_ui_color
signal carry_over
signal carry_back

@onready var pixel_world = get_node_or_null("PixelWorld")
@onready var sound_effects = get_node_or_null("SoundEffects")
@onready var switch_scene_sound = load("res://Assets/little_button_sound.wav")


var ui_color 
var game_path 
var sub_scenes
var backgrounds
var ext_map_idx


# Array of open games
var open_games=[]

var active_scene_idx=0

func _ready():
	set_ui_color()
	set_sub_scenes()
	set_game_path()
	set_backgrounds()
	
	
	if !visibility_changed.is_connected(_on_visibility_changed):
		visibility_changed.connect(_on_visibility_changed)
	
	# Load all sub games
	for scene in sub_scenes:
		var game_name = game_path+scene
		var game = load(game_name).instantiate()
		open_games.append(game)
		connect_to_signals(game, sub_scenes.find(scene))
	set_new_active_scene(active_scene_idx)


func set_ui_color():
	return
	
func set_sub_scenes():
	return
	
func set_game_path():
	return
	
func set_backgrounds():
	return
	
func set_current_background(idx):
	return

		

# Set new active subgame in pixelworld
func set_new_active_scene(idx):
	# Terminate dialog when subgame changes
	emit_signal("terminate_dialog")
	
	# Get Rid of current game
	if pixel_world != null:
		pixel_world.clear_current_sub_game()
	
	# Clear non-permanent carryover nodes
	for child in $CarryOver/Nodes.get_children():
		if child.has_meta("permanence"):
			if !child.get_meta("permanence"):
				child.queue_free()
				
	# Set the new sub game
	pixel_world.set_sub_game(open_games[idx])
	# Set new background and pixelframe color
	set_current_background(idx)
	emit_signal("update_ui_color", ui_color)
	# Update sub scene
	active_scene_idx = idx


		
		
# Load previous scene
func _on_left_button_pressed():
	sound_effects.set_stream(switch_scene_sound)
	$SoundEffects.playing = true
	if active_scene_idx != 0:
		set_new_active_scene(active_scene_idx-1)
	else:
		set_new_active_scene(sub_scenes.size()-1)

# Load next scene
func _on_right_button_pressed():
	sound_effects.set_stream(switch_scene_sound)
	$SoundEffects.playing = true
	if active_scene_idx < sub_scenes.size()-1:
		set_new_active_scene(active_scene_idx+1)
	else:
		set_new_active_scene(0)
		
		
# Return to exterior map
func _on_portal_pressed():
	emit_signal("enter_portal", ext_map_idx)

func _carry_over(node, pos, permanent=true):
	node.call_deferred("reparent", ($CarryOver/Nodes))
	node.global_position = pos
	node.set_meta("permanence", permanent)

	
func _carry_back(node):
	node.call_deferred("reparent", pixel_world.get_sub_game())


# connect subgame to Interior signals
func connect_to_signals(game, game_index):
	# Connect subgame signals to script methods
	if !game.display_text.is_connected(_display_text):
		game.display_text.connect(_display_text)
	if !game.carry_over.is_connected(_carry_over):
		game.carry_over.connect(_carry_over)
	if !game.carry_back.is_connected(_carry_back):
		game.carry_back.connect(_carry_back)
	if !game.mouse_entered.is_connected(_on_button_mouse_entered):
		game.mouse_entered.connect(_on_button_mouse_entered)
	if !game.mouse_exited.is_connected(_on_button_mouse_exited):
		game.mouse_exited.connect(_on_button_mouse_exited)


# Ensure Carryover nodes are changing with visibility
func _on_visibility_changed():
	$CarryOver/Nodes.visible = visible

func dialog_finished():
	var subgame = pixel_world.get_sub_game()
	if subgame:
		subgame.dialog_finished()
	
	
# Delete all open games
func _on_tree_exiting():
	for game in open_games:
		if is_instance_valid(game):
			game.call_deferred("free")
			await get_tree().process_frame
			
func save_game():
	if active_scene_idx == 0:
		open_games[active_scene_idx].save_game()
