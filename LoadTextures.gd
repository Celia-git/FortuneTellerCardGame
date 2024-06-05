extends Node


func get_profile_icon(type):
	var file_path = Globals.profile_icon_path % [type]
	var texture = load(file_path)
	var image = texture.get_image()
	image.resize(40, 40)
	var new_texture = ImageTexture.create_from_image(image)
	return new_texture


func get_image_data(filename):
	var image_data_file = FileAccess.open("res://ImageDataSheet1.txt", FileAccess.READ)
	var item_data_dict = {}
	while image_data_file.get_position() < image_data_file.get_length():
		# Read data
		var line = image_data_file.get_line().split("/")
		if line[1]==filename:
			var pos = Vector2(int(line[2]), int(line[3]))
			var size = Vector2(int(line[4]), int(line[5]))
			var frames = int(line[6])
			var sprites = int(line[7])
			item_data_dict[line[0]]=[pos, size, frames, sprites]
	return item_data_dict

# images with multiple frames or sprites return an array of atlases
func get_atlas(image_file_name,item_name, item_array):
	var image_file = "res://Assets/"+image_file_name
	var pos = item_array[0]
	var frames = item_array[2]
	var sprites = item_array[3]
	var size = Vector2(item_array[1].x/frames, item_array[1].y/sprites)
	var atlases = []
	# Returns an array of atlases with sprite+frame metadata
	for s in range(sprites):
		for f in range(frames):
			var atlas = AtlasTexture.new()
			atlas.atlas = load(image_file)
			var new_position = pos + Vector2(f*size.x,s*size.y)
			atlas.set_region(Rect2(new_position, size))
			atlas.set_meta("sprite", s)
			atlas.set_meta("frame", f)
			atlases.append(atlas)
	return atlases


# position is place among icons ie: row 2, col 3
func get_atlas_all_args(image_file_name, pos, size, size_override=null):
	
	# Set Size override not working as expected
	var texture = load("res://Assets/"+image_file_name)
	if size_override:
		texture.set_size_override(Vector2(size_override, size_override))
		var image_file = "res://Assets/"+image_file_name
	var atlas = AtlasTexture.new()
	atlas.atlas = texture
	var new_position = pos * size
	atlas.set_region(Rect2(new_position, size))
	return atlas
	
# returns [layer0[], layer1:Dict{"filename":image}]
#func get_profile_backgrounds():
#	var layer0 = []
#	var layer1 = {}
#
#	var file_path = Globals.profile_background_path
#	var dir = DirAccess.open(file_path)
#
#	if dir:
#		dir.list_dir_begin()
#		var folder_path = dir.get_next()
#		while folder_path != "":
#			if dir.current_is_dir():
#
#				var folder = DirAccess.open(file_path+folder_path)
#				folder.list_dir_begin()
#				var image = folder.get_next()
#
#				match folder_path:
#
#					"Layer0":
#						while image != "":
#							var full_path = file_path+folder_path+"/"+image
#							if ResourceLoader.exists(full_path, "Texture2D"):
#								var load_image = load(full_path)
#								if load_image is Texture2D:
#									layer0.append(load_image)
#							image = folder.get_next()
#
#					"Layer1":
#						while image != "":
#							var full_path = file_path+folder_path+"/"+image
#							if ResourceLoader.exists(full_path, "Texture2D"):
#								var load_image = load(full_path)
#								if load_image is Texture2D:
#									layer1[image] = load_image
#							image = folder.get_next()
#
#			folder_path = dir.get_next()
#	else:
#		print("An error occurred when trying to access the path.")
#
#	return [layer0, layer1]
