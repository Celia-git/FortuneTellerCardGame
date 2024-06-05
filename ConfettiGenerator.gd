extends Node2D

var confetti_types = ["sprinkles", "tickets", "hearts", "diamonds", "popper", "face", "circles", "triangles"]
var confetti_tiles = {"sprinkles":[], "tickets":[], "hearts":[],"diamonds":[],"popper":[],"face":[],"circles":[],"triangles":[]}
var confetti_tile_size = Vector2(16, 16)
var image_file = "res://Assets/confetti_tiles.png"
var current_confetti_type = "diamonds"

@onready var emitter1 = $CPUParticles2D
@onready var emitter2 = $CPUParticles2D2
@onready var emitter3 = $CPUParticles2D3

func _ready():
	load_confetti_tiles()

# Create Atlas Textures, save in confetti tiles[] 
func load_confetti_tiles():
	var y = 0
	for type in confetti_types:
		var x = 0
		while x < 127:
			
			var atlas = AtlasTexture.new()
			atlas.atlas = load(image_file)
			atlas.set_region(Rect2(Vector2(x, y), confetti_tile_size))
			confetti_tiles[type].append(atlas)
			x += confetti_tile_size.x
		
		y += confetti_tile_size.y

func start(direction:Vector2, emission_shape:int, amount:int):
	if current_confetti_type in confetti_types:
		for emitter in [emitter1, emitter2, emitter3]:
			emitter.texture = confetti_tiles[current_confetti_type][randi_range(0, 7)]
			emitter.direction = direction
			emitter.emission_shape = emission_shape
			emitter.amount = amount
			emitter.emitting = true
		$AudioStreamPlayer2D.playing = true
	
func stop():
	for emitter in [emitter1, emitter2, emitter3]:
		emitter.emitting = false
	
func set_confetti_type(type):
	if type=="random":
		current_confetti_type = confetti_types[randi_range(0, confetti_types.size()-1)]
	else:
		current_confetti_type = type
		
