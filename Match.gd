extends Control

signal match_finished
var images = {}
var all_textures = []

func _ready():
	
	visible = false
	

func display_new_character(element, stage, role):
	
	var new_image = images[element].get_image()
	var layer1_img = images[stage].get_image()
	var layer2_img = images[role].get_image()
	
	var new_img_size = new_image.get_size()
	for x in range(new_img_size.x):
		for y in range(new_img_size.y):
			var layer2_pixel = layer2_img.get_pixelv(Vector2(x, y))
			if layer2_pixel.a == 1:
				new_image.set_pixelv(Vector2(x, y), layer2_pixel)
				continue
			var layer1_pixel = layer1_img.get_pixelv(Vector2(x, y))
			if layer1_pixel.a == 1:
				new_image.set_pixelv(Vector2(x, y), layer1_pixel)
				continue

	var new_texture = ImageTexture.create_from_image(new_image)
	all_textures.append(new_texture)
	$TextureRect.texture = new_texture
	$AnimationPlayer.play("ShowMatch")
	visible = true
	
func get_character_texture():
	
	return all_textures.back()

func _on_timer_timeout():
	$AnimationPlayer.play("HideMatch")

func _on_animation_player_animation_finished(anim_name):
	if anim_name=="ShowMatch":
		$Timer.start()
	elif anim_name=="HideMatch":
		visible = false
		emit_signal("match_finished")
