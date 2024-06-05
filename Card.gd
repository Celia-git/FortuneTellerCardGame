extends Container

class_name Card

signal selected
signal add_to_hand
signal animation_over
signal mouse_entered_area
signal mouse_exited_area

@onready var sprite = $Sprite2D
var speed = 5
var type
var title
var index
var default_texture
var selected_texture

var destination_position = Vector2(0,0)
var destination_rect = Rect2()

var discard_scale = Vector2(.8, .3)
var discard_skew = deg_to_rad(42)

func _ready():
	set_process(false)
	position = Vector2(0,0)

func _process(delta):

	if destination_position != null:
		global_position = lerp(global_position, destination_position,speed*delta)
	if destination_rect.has_point(global_position): 
		emit_signal("add_to_hand", self)
		set_process(false)

func set_values(ty, tit, ind):
	self.type=ty
	self.title=tit
	self.index=ind

# Set image and collision shape based on image size
func set_image(texture, texture1=null):
	default_texture = texture
	selected_texture = texture1
	set_custom_minimum_size(texture.region.size/2)
	$Sprite2D.texture= texture
	var shape = RectangleShape2D.new()
	shape.size.x = texture.region.size.x/2
	shape.size.y = texture.region.size.y
	$Area2D/CollisionShape2D.shape = shape
	$Sprite2D.set_modulate(Color(1, 1, 1, 1))
	$Frame.visible = shape.size.y==32
	

func set_color(color):
	$Sprite2D.set_modulate(color)

func move(from, to, rect):
	global_position = from
	destination_position = to
	destination_rect = rect
	set_process(true)


func play_animation(arg, reverse=false, speed_scale = 1):
	$AnimationPlayer.speed_scale = speed_scale
	if reverse:
		$AnimationPlayer.play_backwards(arg)
	else:
		$AnimationPlayer.play(arg)
	if arg == "select" || arg == "deselect":
		if arg=="select" and selected_texture != null:
			$Sprite2D.texture = selected_texture
		elif arg=="deselect":
			$Sprite2D.texture = default_texture
		$Frame.play(arg)
	elif arg=="discard":
		$Frame.visible = false

func _on_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("click"):
		emit_signal("selected", self)


func _on_animation_player_animation_finished(anim_name):
	$AnimationPlayer.speed_scale = 1
	emit_signal("animation_over")


func _on_area_2d_mouse_entered():
	emit_signal("mouse_entered_area")


func _on_area_2d_mouse_exited():
	emit_signal("mouse_exited_area")


func _on_frame_animation_finished():
	if $Frame.animation == "select":
		$Frame.play("loop")
		
func _free_self():
	if is_inside_tree():
		queue_free()
	else:
		call_deferred("free")
		


func _free_if_orphaned():
	if !is_inside_tree() and destination_rect == Rect2():
		call_deferred("free")
	
func _mute(mute):
	$AudioStreamPlayer2D.volume_db = [0, -80][int(mute)]
