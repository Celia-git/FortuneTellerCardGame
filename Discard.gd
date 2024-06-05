extends Node2D

@onready var pos = global_position
@onready var rect_size = Vector2(100, 30)
@onready var container_rect = Rect2(pos-(rect_size/2), rect_size)
@onready var empty_atlas = AtlasTexture.new()

signal discard_over
signal return_card
signal update_label
var images = {}
var cards = []
var showing_card
var display = false
var max_pile_size = 0
@export var discard_skew = .9
@export var discard_scale = .4

func _ready():set_pile_size()

func add_cards(new_cards):
	cards.append_array(new_cards)
	if !new_cards.is_empty():
		showing_card = cards.back()
		for card in new_cards:
			if card == null:
				continue
			card.set_image(images[card.title])
			if !card.is_connected("selected", _card_selected):
				card.selected.connect(_card_selected)
			if !card.is_connected("add_to_hand", _card_added):
				card.add_to_hand.connect(_card_added)
			if card.get_parent():
				card.reparent(self)
			else:
				add_child(card)
			card.move(card.get_meta("last_position"), self.global_position, container_rect)
			await get_tree().create_timer(.2).timeout
	

func _card_added(card):

	set_pile_size()
	if card.title=="Joker":
		cards.erase(card)
		card.queue_free()
	
	if card == showing_card:
		card.play_animation("discard", false, 3)
		disconnect_signals(card)
		await get_tree().create_timer(.2).timeout
		for child in get_children():
			if (child != showing_card) && (child.name != "Sprite2D") && (child.get_parent()==self):				
				remove_child(child)
	
	emit_signal("discard_over")

	
func display_cards():
	if !showing_card:
		showing_card=cards.back()
	display = true
	var row = 0 
	var col = 0	

	emit_signal("update_label")
	var tween1 = create_tween()
	tween1.tween_property(showing_card.sprite, "scale", Vector2(1,1), .1)
	for card in cards:
		card.set_image(images[card.title])
		if !card.is_connected("selected", _card_selected):
			card.selected.connect(_card_selected)
		if card != showing_card:
			if card.get_parent():
				card.reparent(self)
			else:
				add_child(card)
		
		var tween = create_tween()
		tween.parallel().tween_property(card.sprite, "skew", 0, discard_skew)
		tween.parallel().tween_property(card.sprite, "scale", Vector2(1,1), discard_scale)
		tween.parallel().tween_property(card, "position", Vector2(1.5*col*card.size.x, -2*row*card.size.y), .5)
		card.play_animation("deselect")
		col += 1
		
		# New row every 12 columns
		if (col % 8 == 0):
			col = 0
			row += 1
	
		
func collapse_display():
	var tween = create_tween()
	display = false
	for card in cards:
		card.play_animation("discard")
		tween.parallel().tween_property(card, "position", Vector2(0, 0), .3)
		_card_added(card)
		
		
func _card_selected(card):
	
	disconnect_signals(card)
	cards.erase(card)
	if card.get_parent()==self:
		remove_child(card)
	
	if card == showing_card:
		if cards:
			showing_card = cards.back()
		else:
			showing_card= null
	
	
	collapse_display()
	
	emit_signal("return_card", card, get_parent().player.hand.size(), global_position)	

# Return and remove cards from discard pile
func get_cards():
	var temp_stack = cards.duplicate(true)
	for card in cards:
		card.set_meta("last_position", self.global_position)
		disconnect_signals(card)
		cards.erase(card)
		if card==showing_card and card.get_parent()==self:
			remove_child(card)
	set_pile_size()
	return temp_stack

# Change the size of the pile sprite to reflect the discard pile
func set_pile_size():
	if cards.size() <= 1:
		$Sprite2D.visible = false
	else:
		$Sprite2D.visible = true
		# Get Scale and Skew of Sprite to current top card dimentions
		var card_scalar = cards[0].discard_scale
		var card_skew = cards[0].discard_skew 
		$Sprite2D.scale = card_scalar

func disconnect_signals(card):
	if card.is_connected("selected", _card_selected):
		card.selected.disconnect(_card_selected)
	if card.is_connected("add_to_hand", _card_added):
		card.add_to_hand.disconnect(_card_added)

func delete_cards():
	for card in cards:
		card.queue_free()
	cards.clear()
