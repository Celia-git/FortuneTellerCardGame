extends Area2D

class_name Deck


signal draw_card
signal empty_deck
signal play_shuffle_sound
const DECK_SIZE = 4
var CARDSCENE = preload("res://Card.tscn")
var CARDTYPES = preload("res://CardType.gd")
var cards = []
var types = {}
var top_card_texture
var max_deck_size

	
func populate():
	
	var idx = 0
	var cardtypes = CARDTYPES.new()
	types = cardtypes.get_types()
	for cardtype in types:
		var w=0
		var weight = cardtype["weight"]*DECK_SIZE
		while w < weight:
			for subtype in cardtype["subcategories"]:
				var card = CARDSCENE.instantiate()
				card.set_values(cardtype, subtype, idx)
				
				get_parent().mute_sounds.connect(card._mute)
				card.mouse_entered_area.connect(get_parent()._mouse_entered)
				card.mouse_exited_area.connect(get_parent()._mouse_exited)
				Globals.free_all_orphans.connect(card._free_if_orphaned)
				cards.append(card)
				idx += 1
			w += 1
	var card = CARDSCENE.instantiate()
	card.set_values(cardtypes.get_joker(), "Joker", idx)
	card.mouse_entered_area.connect(get_parent()._mouse_entered)
	card.mouse_exited_area.connect(get_parent()._mouse_exited)
	cards.append(card)
	max_deck_size = cards.size()	
	shuffle()
	

func draw():
	# Remove and Return the top card
	var top_card = cards.pop_front()
	var offset = set_pile_size()
	if cards.size()>0:
		set_top_texture(offset)
	else:
		emit_signal("empty_deck")
		
	return top_card

func replace(new_cards):
	cards.append_array(new_cards)
	var offset = set_pile_size()
	set_top_texture(offset)
	shuffle()

func shuffle():
	# randomize cards in deck
	emit_signal("play_shuffle_sound")
	cards.shuffle()
	set_top_color()
	

func set_pile_size():
	if cards.size() <= 1:
		$Bottom.visible = false
		return Vector2(0,0)
	else:
		$Bottom.visible = true
		var tween = create_tween()
		var scalar = Vector2(1, float(cards.size())/max_deck_size)
		tween.tween_property($Bottom, "scale", scalar, 1)
		tween.tween_property($TopCard, "scale", scalar, 1)
		
		return Vector2(0, 1-scalar.y)
		
	
func set_image(texture):
	$Bottom.set_texture(texture)

func set_top_card(top_card):
	var shape = RectangleShape2D.new()
	shape.size = top_card.region.size
	$CollisionShape2D.set_shape(shape)
	top_card_texture = top_card
	set_top_texture()

func set_top_texture(offset=Vector2(0,0)):
	$TopCard.set_texture(top_card_texture)
	$TopCard.offset = offset
	set_top_color()
	
func set_top_color():
	var c = cards[0].type["color"]
	$TopCard.set_modulate(c.lightened(.15))
	
	
	
func get_types():
	return types


func _on_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("click"):
		emit_signal("draw_card")
