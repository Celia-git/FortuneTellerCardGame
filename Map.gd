class_name Map

extends Node2D

const FULLSCREEN_SIZE = Vector2(1920, 1080)
const WINDOWED_SIZE = Vector2(1600, 900) 

var fullscreen = false
var mini_map_changed = true
var load_script # Script from which states are loaded
var texture_script # Script from which background textures are loaded
#var background_textures = [] # [array of layer0 textures, dict of layer1 textures]
var guestbook # User interface for loading files
var main = null# Main active scene
var pixel_frame_visible:bool=false
var keep_dialog_visible = false

@onready var dialogbox = $CanvasLayer/DialogBox
@onready var pixelframe = $CanvasLayer/PixelFrame
#@onready var minimap = $CanvasLayer/Minimap
#@onready var minimap_anchor_mask = $CanvasLayer/Minimap/AnchorMask
#@onready var minimap_dot_mask = $CanvasLayer/Minimap/DotMask
#
#@onready var background0_sprite = $Background/Layer0/Sprite2D 
#@onready var background1A_sprite = $Background/Layer1/Sprite2D 
#@onready var background1B_sprite = $Background/Layer2/Sprite2D 
#
#var player  


# When map enters tree, popup guest book
func _ready():
	load_script = Globals.load_states.new()
	load_script.save_finished.connect(_save_finished)
	texture_script = Globals.texture_script.new()
	Globals.add_to_canvas.connect(_add_to_canvas)
	_load_game_file()
	

# Called when main scene is changed
func _add_main_scene():
	if main != null:
		main.call_deferred("queue_free")
	# Add Fortune Teller map to tree
	main = load_script.get_setting(2, "Interior")
	
	if !main.display_text.is_connected(_display_text):
		main.display_text.connect(_display_text)
	if !main.terminate_dialog.is_connected(_terminate_dialog):
		main.terminate_dialog.connect(_terminate_dialog)
#	if !main.image_ready.is_connected(_save_screenshot):
#		main.image_ready.connect(_save_screenshot)
	if !main.first_interaction.is_connected(_game_not_saved):
		main.first_interaction.connect(_game_not_saved)
#	if !main.enter_portal.is_connected(_enter_portal):
#		main.enter_portal.connect(_enter_portal)
	if is_instance_of(main, InteriorScenes):			
		main.active_scene_idx = 0
		#main.ext_map_idx =player.get_previous_map_idx()
		pixel_frame_visible = true
		if !main.update_ui_color.is_connected(_set_pixel_frame_color):
			main.update_ui_color.connect(_set_pixel_frame_color)
			
		if !main.tree_exiting.is_connected(_save_game.bind(main.active_scene_idx)):
			main.tree_exiting.connect(_save_game.bind(main.active_scene_idx))
		
#	if is_instance_of(main, ExteriorScenes):
#		pixel_frame_visible = false
#		if !main.change_overworld_setting.is_connected(_change_overworld_setting):
#			main.change_overworld_setting.connect(_change_overworld_setting)
		
	main.setting_index = 2
	
	add_child(main)
	
	_set_pixel_frame_visibility()

func _input(event):
	
	# 	TOGGLE FULLSCREEN
	
	if event.is_action_pressed("toggle_fullscreen") and !fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		get_viewport().size = FULLSCREEN_SIZE
		fullscreen=true
	elif event.is_action_pressed("toggle_fullscreen") and fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		get_viewport().size = WINDOWED_SIZE
		fullscreen=false
	
#	#	TOGGLE PROFILE
#
#	elif event.is_action_pressed("toggle_profile") and player != null:
#		match $CanvasLayer/Profile.visible:
#			true:
#				$CanvasLayer/Profile.visible = (false)
#				_on_button_mouse_exited()
#			false:
#				if !$CanvasLayer/Guestbook.visible:
#					$CanvasLayer/Profile.show_profile()
				
	#	TOGGLE MINIMAP
#	elif event.is_action_pressed("minimap") and main != null:
#		match minimap.visible:
#			true:
#				minimap.visible = false
#				_on_button_mouse_exited()
#			false:
#				if is_instance_of(main, ExteriorScenes):
#					if mini_map_changed:
#						load_minimap_texture()
#					minimap.visible = true
	
		
## Switch from inside->outside or outside->inside	
#func _enter_portal(destination:int, subgame:int=0):
#
#	# Going Outside
#	if is_instance_of(main, InteriorScenes):
#		player.set_active_map_type("Exterior")
#		player.set_active_map_idx(destination)
#	# Going Inside
#	else:
#		player.set_active_map_type("Interior")
#		player.set_current_subgame(subgame)
#		player.set_previous_map_idx(player.get_active_map_idx())
#		player.set_active_map_idx(destination)
#
#	_add_main_scene()
			
## Change main scene to a new overworld setting
#func _change_overworld_setting(setting_idx:int):
#	player.set_previous_map_idx(player.active_map_idx)
#	player.set_active_map_idx(setting_idx) 
#	mini_map_changed=true
#	if minimap.visible:
#		load_minimap_texture()
#	main.load_map(setting_idx)
#
#
# Show text in dialog box
func _display_text(text, keep_vis=false, autoplay=false):
	if !dialogbox.await_input:
		dialogbox.play_text(text, autoplay)
	keep_dialog_visible = keep_vis

# Hides text; (esp when subgame changes)
func _terminate_dialog():
	Input.set_custom_mouse_cursor(Globals.default_cursor)
	dialogbox.force_stop()

# Text animation has finished
func _on_dialog_box_text_finished():
	dialogbox.visible = keep_dialog_visible
	if main:
		main.dialog_finished()
		
func _set_pixel_frame_color(color):
	pixelframe.set_self_modulate(color)
	
func _set_pixel_frame_visibility(background_visible=false):
	if background_visible:
		pixelframe.visible = false
	else:	
		pixelframe.visible = pixel_frame_visible

	
	
	
#############	LOAD AND SAVE GAME AND PLAYER STATES	#############
	
# Called by guestbook
func _load_game_file():
	
	# Load player data
#	Globals.player = load_script.load_player(username)
#	player = Globals.player
	var game_states = load_script.load_game_data()
	Globals.game_states = game_states
	#_on_toggle_mouse_tail(player.get_mouse_trail_enabled())
	_add_main_scene()
	
	# Load saved audio settings from player file
#	for setting_type in ["Sound Effects", "Music", "All Volume"]:
#		if !(setting_type in player.settings.keys()):
#			continue
#		var bus_idx = 0
#		var value = player.get_settings()["All Volume"]
#		if setting_type in ["Sound Effects", "Music"]:
#			bus_idx = AudioServer.get_bus_index(setting_type)
#			value = player.get_settings()[setting_type]
#
#		if bus_idx >= 0 and bus_idx < AudioServer.bus_count:	
#			AudioServer.set_bus_volume_db(bus_idx, float(value))
	
	# Load + Show player profile 
#	var image = load_script.load_image(username)
#	$CanvasLayer/Profile.just_saved=true
#	$CanvasLayer/Profile.show_profile(image)

# Game Closing, save player stats
#func _save_game(terminate):
#
#	# Save player data from profile (user edits name, settings)
#	var profile = $CanvasLayer/Profile
#
#
#	player.set_settings(profile.get_player_settings())
#	load_script.terminate_next = terminate
#	load_script.save_player(player, player.get_player_name())
#	load_script.save_game_data(Globals.game_states, player.get_player_name())
#
#	# Save screenshot from current main scene
#		# Save any changes to settings
#	if main != null:
#		player.set_active_map_idx(main.setting_index)
#		player.set_active_map_type("Interior")
#		if player.get_active_map_type()=="Interior":
#			player.set_current_subgame(main.active_scene_idx)
#		else:
#			player.set_current_subgame(0)
#		$CanvasLayer/Profile.visible = false
#		$CanvasLayer/Guestbook.visible = false
#		main.take_screenshot()
#	else:
#		load_script.image_saved = true
#		load_script.check_saves()
#
	
## Called by profile
#func _reload_game_file():
#	if player != null:
#		_load_game_file(player.get_player_name())
#
#func _rename_game_file(old_name, new_name):
#
#	if !$CanvasLayer/Guestbook.is_new_name(new_name):
#		$CanvasLayer/Profile.show_error("Can't rename to %s.\nAlready a game file" % [new_name])
#		$CanvasLayer/Profile.visible = true
#	else:
#		player.set_player_name(new_name)
#		_save_game(false)
#		$CanvasLayer/Guestbook._trash_selected(old_name, false)
#		_load_game_file(new_name)
	

# Save all mini game data on scene close
func _save_game(setting_idx):
	if main != null and !load_script.game_data_saved:
		main.save_game()
		load_script.save_game_data(Globals.game_states)
		#player.set_current_subgame(setting_idx)
		
# Emitted by main scene when player interacts for first time
func _game_not_saved():
	if main != null:
		$CanvasLayer/Profile.just_saved = false

## Recieved when main emits "image_ready"
#func _save_screenshot():
#	var image = get_viewport().get_texture().get_image()
#	load_script.save_image(image, player.get_player_name())


# When LoadStates has finished saving each component, terminate or continue
func _save_finished(terminate):
	
	await get_tree().process_frame	
	Globals.emit_signal("free_all_orphans")
	await get_tree().process_frame
	if main !=null:
		main.call_deferred("queue_free")
	if terminate:
		quit_game()
	# Open guestbook
#	else:
#		$CanvasLayer/Profile.just_saved=true
#		_on_toggle_mouse_tail(false)
#		$CanvasLayer/Guestbook.view()

# Terminate game
func quit_game():
	Node2D.print_orphan_nodes()
	get_tree().quit()
	
	
############### 	CHANGE CURSOR      #################
# Highlight Mouse
func _on_button_mouse_entered():
	Input.set_custom_mouse_cursor(Globals.select_cursor)

#Undo highlight mouse
func _on_button_mouse_exited():
	Input.set_custom_mouse_cursor(Globals.default_cursor)

func _on_line_edit_mouse_entered():
	Input.set_custom_mouse_cursor(Globals.text_cursor)

##############	EDIT CURSOR VARIABLES ####################

#func _on_toggle_mouse_tail(on:bool):
#	if Globals.mouse_tail != null:
#		Globals.mouse_tail.queue_free()
#	if on:
#		var settings = player.get_settings()
#		Globals.mouse_tail = load(Globals.mouse_tail_script % [player.get_settings()["Cursor"]]).new(settings["mouse_tail_length"], settings["mouse_tail_action"], Globals.get_mouse_icons(settings["Cursor"])[0])
#		if Globals.mouse_tail.has_signal("add_to_canvas"):
#			Globals.mouse_tail.add_to_canvas.connect(_add_to_canvas)
#		$CanvasLayer.add_child(Globals.mouse_tail)
#	player.set_mouse_trail_enabled(on)
#
#func _on_profile_change_mouse_tail_variables(variable, value):
#	match variable:
#		"mouse_tail_length":
#			_on_set_mouse_tail_length(value)
#		"mouse_tail_action":
#			_on_set_mouse_tail_action(value)
#
#func _on_set_mouse_tail_length(ln:int):
#	if Globals.mouse_tail == null:
#		_on_toggle_mouse_tail(true)
#	Globals.mouse_tail.set_length(ln)
#
#func _on_set_mouse_tail_action(act:int):
#	if Globals.mouse_tail == null:
#		_on_toggle_mouse_tail(true)
#	Globals.mouse_tail.set_action(act)
	
## Show/hide background based on whether profile or guestbook is popped up
#func _on_profile_visibility_changed():
#	if main !=null:
#		main.visible = !($CanvasLayer/Profile.visible || $CanvasLayer/Guestbook.visible)
#		if !main.visible:
#			_terminate_dialog()
#
#	# Load Layer 0 and 1 Background 
#	$Background.visible = ($CanvasLayer/Profile.visible || $CanvasLayer/Guestbook.visible)
#
#	if $Background.visible and !background_textures.is_empty():
#		load_background_textures()
#	_set_pixel_frame_visibility($Background.visible)


############# BACKGROUNDS ############

		
# Load the image textures which will be on parallax bg layers
#func load_background_textures():
#	var max0_size = background_textures[0].size()-1
#	background0_sprite.texture = background_textures[0][randi_range(0, max0_size)]
#	var top_layer_backgrounds = background_textures[1].keys()
#	var top_layerA_backgrounds = []
#	for layer in top_layer_backgrounds:
#		if "0" in layer:
#			top_layerA_backgrounds.append(layer)
#	var layer1A_background_name = top_layerA_backgrounds[randi_range(0, top_layerA_backgrounds.size()-1)]
#	var layer1B_background_name = layer1A_background_name.split("_")[0]
#	layer1B_background_name += "_1.png"
#	var layer1A_texture = background_textures[1][layer1A_background_name]
#	var layer1B_texture = background_textures[1][layer1B_background_name]
#	layer1A_texture.set_meta("name", layer1B_background_name.trim_suffix("_1.png"))
#	layer1B_texture.set_meta("name", layer1B_background_name.trim_suffix("_1.png"))
#	background1A_sprite.texture = layer1A_texture
#	background1B_sprite.texture = layer1B_texture

#
## Sync Profile Background animation
#func _background_sync_start_timer():
#	if $Timer.is_stopped():
#		$Timer.start(4)
#
## Background sync over
#func _on_timer_timeout():
#	$Background/Layer1.start_cycle()
#	$Background/Layer2.start_cycle()


############ MINIMAP METHODS ###################
#
## Show/hide minimap placement controls
#func _on_minimap_mouse_entered():
#	_on_button_mouse_entered()
#	minimap.mouse_filter = Control.MOUSE_FILTER_IGNORE
#	minimap_anchor_mask.visible = true
#
#func _on_anchor_mask_mouse_exited():	
#	_on_button_mouse_exited()
#	minimap.mouse_filter = Control.MOUSE_FILTER_PASS
#	minimap_anchor_mask.visible = false
#
#func _on_minimap_placement_selected(arg:int):
#	minimap.set_anchors_preset(arg, true)
#	minimap.force_update_transform()
#	await get_tree().process_frame
#	if minimap.position.x < 0: minimap.position.x = 0
#	if minimap.position.y < 0: minimap.position.y = 0
#	if minimap.position.y == get_viewport_rect().size.y:
#		minimap.position.y -= minimap.size.y
#	if minimap.position.x == get_viewport_rect().size.x:
#		minimap.position.x -= minimap.size.x
#
## Update minimap with data ( current position, previous position) 
#func load_minimap_texture():
#
#	var mask_size = Vector2(143, 94)
#	var dot_positions = [
#		Vector2(10, 47),
#		Vector2(35, 47),
#		Vector2(54, 24),
#		Vector2(82, 34), 
#		Vector2(98, 48),
#		Vector2(98, 48),
#		Vector2(127, 47),
#		Vector2(85, 58),
#		Vector2(73, 62),
#		Vector2(58, 64)
#		]
#
#	var dot_mask_image = Image.create(mask_size.x, mask_size.y, false, Image.FORMAT_RGBA8)
#
#	# Set colors in minimap dots
#	for i in range(10):
#		if (i==4)||(i==5):
#			continue
#		var arg=""
#		if i ==	player.get_previous_map_idx():
#			arg = "previous_"
#		elif i == player.get_active_map_idx():
#			arg = "current_"
#		write_dot(arg, dot_positions[i], dot_mask_image)
#
#
#	# Set map dots 4 and 5
#	var map_dot_4=""
#	if player.get_previous_map_idx()==4:
#		map_dot_4 = "previous_"
#	elif player.get_active_map_idx()==4:
#		map_dot_4 = "current_"
#
#	var map_dot_5=""
#	if player.get_previous_map_idx()==5:
#		map_dot_5 = "previous_"
#	elif player.get_active_map_idx()==5:
#		map_dot_5 = "current_"
#
#	# Split dots 4-5
#	if map_dot_4 != map_dot_5:
#		var left_image = load(Globals.minimap_dot_path % [map_dot_5])
#		var right_image = load(Globals.minimap_dot_path % [map_dot_4])
#		var dot_image_offset = Vector2(left_image.get_width()/2, left_image.get_height()/2)
#		var dot_image_position = Vector2i(dot_positions[4]-dot_image_offset)
#		var dot_image = left_image
#		for x in range(dot_image.get_width()):
#			for y in range(dot_image.get_height()): 
#				var val = dot_image.get_pixelv(Vector2i(x, y))
#				if val.a != 0:
#					dot_mask_image.set_pixelv(dot_image_position+Vector2i(x, y), val)
#			if (x == 2):
#				dot_image = right_image
#	else:
#		write_dot(map_dot_4, dot_positions[4], dot_mask_image)
#
#	dot_mask_image.resize(3*mask_size.x, 3*mask_size.y, 0)
#	var texture = ImageTexture.create_from_image(dot_mask_image)
#	minimap_dot_mask.texture = texture
#	mini_map_changed=false

## Write dots to map dot mask 
#func write_dot(dot_type:String, dot_image_pos:Vector2, dot_mask_image:Image):
#	var dot_image = load(Globals.minimap_dot_path % [dot_type])
#	var dot_image_offset = Vector2(dot_image.get_width()/2, dot_image.get_height()/2)
#	var dot_image_position = Vector2i(dot_image_pos-dot_image_offset)
#	for x in range(dot_image.get_width()):
#		for y in range(dot_image.get_height()): 
#			var val = dot_image.get_pixelv(Vector2i(x, y))
#			if val.a != 0:
#				dot_mask_image.set_pixelv(dot_image_position+Vector2i(x, y), val)
#
#

#func _on_anchor_mask_gui_input(event):
#	if event.is_action_pressed("click"):
#
#		var anchor_size = Vector2(96, 96)
#		var mask_size = minimap_anchor_mask.get_rect().size
#		var mouse_pos = (minimap_anchor_mask.get_local_mouse_position())
#
#		# Top-Left anchor selected
#		if Rect2(Vector2(0, 0), anchor_size).has_point(mouse_pos):
#			_on_minimap_placement_selected(0)
#
#		# Top-Right
#		elif Rect2(Vector2(mask_size.x-anchor_size.x, 0), anchor_size).has_point(mouse_pos):
#			_on_minimap_placement_selected(1)
#
#		# Bottom-left
#		elif Rect2(Vector2(0, mask_size.y-anchor_size.y), anchor_size).has_point(mouse_pos):
#			_on_minimap_placement_selected(2)
#
#		# Bottom-right
#		elif Rect2(Vector2(mask_size.x-anchor_size.x, mask_size.y-anchor_size.y), anchor_size).has_point(mouse_pos):
#			_on_minimap_placement_selected(3)

func _add_to_canvas(node):
	$CanvasLayer.add_child(node)




func _on_child_exiting_tree(node):
	if node is CPUParticles2D:
		if (Globals.mouse_tail != null) && !(Globals.mouse_tail in $CanvasLayer.get_children()):
			$CanvasLayer.call_deferred("add_child", (Globals.mouse_tail))
