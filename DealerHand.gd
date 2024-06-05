extends Node2D

@onready var cont = Rect2(700, 520, 260, 16)
var images = []
var selected_images = []
var hand = []
var focused_cards = []

func add_card(card, index, source):
	if index>=images.size():
		index -= images.size()
	card.visible = false
	card.set_image(images[index], selected_images[index])
	card.set_modulate(card.type["color"])
	if !card.is_connected("selected", _card_selected):
		card.selected.connect(_card_selected)
	if !card.is_connected("add_to_hand", _card_added):
		card.add_to_hand.connect(_card_added)
	hand.append(card)
	card.visible = true
	if card.get_parent():
		card.reparent(self)
	else:
		add_child(card)
	card.move(source, get_next_position(index), cont)


# Return position in hand relative to global coordinates
func get_next_position(index):
	var pos = cont.position
	var interval = cont.size.x / get_parent().HAND_SIZE
	if hand.size() > get_parent().HAND_SIZE:
		interval = cont.size.x / hand.size()
	var j = index
	
	while j >= 0:
		var tween = create_tween()
		tween.parallel().tween_property(hand[j], "global_position", Vector2(pos.x+(j*interval), pos.y), .3)
		hand[j]
		j -= 1
	
	return pos


# Return random card from hand
func get_random_card():
	var idx = randi_range(0, hand.size()-1)
	return hand[idx]

func _card_added(card):
	card.reparent(self)
	card.play_animation("deselect")
	card.sprite.skew = 0
	card.sprite.scale = Vector2(1, 1)
	card.sprite.rotation = 0
		
func remove_cards(cards):
	for card in cards:
		card.set_meta("last_position", card.global_position)
		card.play_animation("deselect")
		if card.selected.is_connected(_card_selected):
			card.selected.disconnect(_card_selected)
		if card.add_to_hand.is_connected(_card_added):
			card.add_to_hand.disconnect(_card_added)
		card.set_modulate(Color(1, 1, 1, 1))
		if card in get_children():
			remove_child(card)
		hand.erase(card)
		
	
	get_next_position(hand.size()-1) 
	return
		
func untap():
	for card in focused_cards:
		card.play_animation("deselect")
	focused_cards.clear()
		
func _card_selected(card):
	if card in focused_cards:
		card.play_animation("deselect")
		focused_cards.erase(card)
	else:
		card.play_animation("select")
		focused_cards.append(card)
		
# An array of table card data with sprite and frame metadata
func set_images(atlases):
	images.resize(atlases.size()/2)
	selected_images.resize(atlases.size()/2)
	for atlas in atlases:
		var sprite = atlas.get_meta("sprite")
		var frame = atlas.get_meta("frame")
		[images, selected_images][frame][sprite] = atlas 
