extends Node

signal free_all_orphans
signal add_to_canvas
#
## Godot scripts for loading and saving data
var load_states = load("res://LoadStates.gd")
#
#
## User data files
var user_directory = "user://"
#var player_file = "/Player.tres"
var game_file = "Game.tres"
#var image_file = "/last_scene.png"
#
#var player_script = "res://Player.gd"
var game_script = "res://GameData.gd"
#
#
## Overworld map script
#var boardwalk_script = load("res://Maps/Boardwalk.gd")
#var boardwalk_arrow_script = load("res://UI/OverworldIcons/ui_arrow.gd")
#var boardwalk_portal_script = load("res://UI/OverworldIcons/ui_portal.gd")
#
#
## Sound Data
#var audio_stream_path = "res://Audio/"
#
## Graphics data
var texture_script = load("res://LoadTextures.gd")
#
#var default_cursor_path = "res://Assets/%smouse%d.png"
#var select_cursor_path = "res://Assets/%spointer%d.png"
#var minimap_dot_path = "res://Assets/minimap_%slocation.png"
#
## mouse cursor images
var default_cursor = load("res://Assets/mouse.png")
var dialog_cursor = load("res://Assets/dialog.png")
var select_cursor = load("res://Assets/pointer.png")
var text_cursor = load("res://Assets/cursor.png")
#var mouse_tail
#var mouse_tail_script = "res://UI/mouse_tail_%d.gd"
#var mouse_cursor_count = 4

# Profile and Guestbook image resource data
#var profile_icon_path = "res://UI/profile_%s_icon.tres"
#var profile_background_path = "res://Assets/Backgrounds/Profile/"
#var profile_number_path = "res://UI/profile_number0.tres"
#
##var trash_icon = load("res://UI/OrdersTrash.tres")
#var backgrounds_path = "res://Assets/Backgrounds/"
#var inventory_file = "res://IceCream/Orders/InventoriesIceCreamInventory.txt"
var pixelframe = Rect2(Vector2(320, 180), Vector2(960, 540))
var bigframe = Rect2(Vector2(0,0), Vector2(1600, 900))
## Ordinary pixel label
var label_settings = "res://UI/LabelSettings.tres"
## Notepad order label
#var order_label_settings = "res://UI/OrderLabel.tres"
#
#
#var order_icons_path = "res://UI/Orders"

var colors = {
	
		"Cheese":Color.ORANGE,
		"Caramel":Color.GOLD,
		"Peanut Butter":Color.CHOCOLATE,
		"Chocolate":Color.SADDLE_BROWN,
		"Butter":Color.LIGHT_YELLOW,
		"Chili Oil":Color.RED
}


# Script Contains all scores + ticket info
var game_states

# Script Containing player info
var player

# Return color value associated with string
#func get_color(flavor:String):
#	if flavor in colors.keys():
#		return colors[flavor]
#	else:
#		return Color(1, 1, 1, 1)
#
## Return resource file related to ui icon
#func get_order_icon(icon):
#	var order_icon = load(order_icons_path+icon+".tres")
#	return order_icon

# Load all Inventory of certain type from inventory file: 
	# Param "type" is type of flavor (ie: syrup, topping) that corresponds to a boolean value in inventory file
	# Return dictionary {"flavor name":[texture, icon]}
#func get_inventory(type):
#
#	var inventory_index = [0, "palette", "ice cream", "soda", "syrup", "topping",
#	"iconrow", "iconcolumn", "apple topping", "popcorn sauce"].find(type)
#
#
#	var flavors = {}
#	var textures = Globals.texture_script.new()
#	var item_data = textures.get_image_data("IceCream.png")	
#	var read_file = FileAccess.open(Globals.inventory_file, FileAccess.READ)
#	while read_file.get_position() < read_file.get_length():
#
#		var line =Array(read_file.get_line().split("/"))
#		line.erase("")
#		# Get all flavors of type
#		if line[inventory_index]=="True":
#			var label = line[0]
#			var icon = null
#			var texture = null
#			icon = textures.get_atlas_all_args("iconsheet.png", (Vector2(int(line[7]), int(line[6]))), Vector2(75,75))
#			if label in item_data.keys():
#				texture = textures.get_atlas("IceCream.png",label, item_data[label])[0]		
#			flavors[label] = [texture, icon]
#	return flavors


## Return audio stream
#func get_audio_stream(stream_name:String, ext=".wav"):
#	var audio_stream = load(audio_stream_path+stream_name+ext)
#	return audio_stream
#
## Change current default mouse and pointer
#func switch_mouse(idx):
#	var new_cursor_paths = get_cursor_paths(idx)
#	default_cursor = load(new_cursor_paths[0])
#	select_cursor = load(new_cursor_paths[1])
#	if mouse_tail != null:
#		var len = mouse_tail.get_length()
#		var act = mouse_tail.get_action()
#		mouse_tail.call_deferred("queue_free")
#		mouse_tail = load(mouse_tail_script % [idx]).new(len, act, load(new_cursor_paths[0]))
#		if mouse_tail.has_signal("add_to_canvas"):
#			mouse_tail.add_to_canvas.connect(_add_to_canvas)

# Return Array of texture 2D with mouse texture+ pointer texture
#func get_mouse_icons(idx):
#	var cursor_paths = get_cursor_paths(idx) 
#	var mouse_texture = ResourceLoader.load(cursor_paths[0])
#	var pointer_texture = ResourceLoader.load(cursor_paths[1])
#	return [mouse_texture, pointer_texture]
#
## Return cursor paths for mouse and pointer
#func get_cursor_paths(idx):
#
#	var new_default_cursor_path
#	var new_select_cursor_path
#	if idx == 0:
#		new_default_cursor_path = default_cursor_path.replace("%s", "").replace("%d", "")
#		new_select_cursor_path = select_cursor_path.replace("%s", "").replace("%d", "")
#	else:
#		new_default_cursor_path = default_cursor_path % ["custom_", idx]
#		new_select_cursor_path = select_cursor_path % ["custom_", idx]
#
#	return [new_default_cursor_path, new_select_cursor_path]

func _add_to_canvas(node):
	emit_signal("add_to_canvas", node)
