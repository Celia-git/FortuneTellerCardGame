extends Node2D

signal exchange_cards
signal combo_cards
signal discarded	# emitted when game stage forces player discard and player chooses 1 discard card
signal update_label	
signal discard	# emitted when discard initiated by player
# Special action signals
signal pick_one_discard
signal replace_hand
signal full_exchange
signal get_gold_card
signal add_draw_bonus

signal mouse_entered
signal mouse_exited
signal play_button_sound

@onready var cont= Rect2(520, 600, 540, 64)
@onready var discard_node= get_parent().get_node("Discard")


# Images
var images = {}

# Cards Held // Game states
var hand = []
var focused_cards = []
var draw_tokens = []
var draw_token_values = []
var wait_for_discard = false
var wait_for_game = false

# Button Textures
var default_button_texture = load("res://resources/ButtonBase.tres")
var focused_button_texture = load("res://resources/ButtonBaseFocused.tres")
var pressed_button_texture = load ("res://resources/ButtonBasePressed.tres")

# Dialog options
var special_triggers = ["joker", "match 3", "1 card hand"] 
var special_actions = ["pick 1 from discards (%d)", "get random full hand", "switch cards with dealer","get gold card"]

var labels = {"exchange_failed":"mismatched exchange values",
	"bad_combo":"no combo: need one of each color",
	"char_known":"no combo: already found ",
	"new_combo":"new combo: ",
	"upkeep":"draw from deck",
	"resolve":"discard one card",
	"action":"exchange or combo"
	
	}
	
func _ready():
	for i in range(special_actions.size()):
		$SpecialActionDialog.add_item(special_actions[i], i)
	for i in range(special_triggers.size()):
		$SpecialTriggerDialog.add_item(special_triggers[i], i)
	
func add_card(card, index, source):
	card.visible = false
	card.set_image(images[card.title])
	card.set_modulate(Color(1, 1, 1, 1))
	if !card.is_connected("selected", _card_selected):
		card.selected.connect(_card_selected)
	if !card.is_connected("add_to_hand", _card_added):
		card.add_to_hand.connect(_card_added)
	hand.insert(index, card)
	card.visible = true
	if card.get_parent():
		card.reparent(self)
	else:
		add_child(card)
	card.move(source, get_next_position(index), cont)
	

func _card_added(card):
	card.reparent(self)
	card.play_animation("deselect")
	card.sprite.skew = 0
	card.sprite.scale = Vector2(1, 1)
	card.sprite.rotation = 0

# Return position in hand relative to global coordinates
func get_next_position(index):
	var x_pos = cont.position.x + (cont.size.x-32)
	var interval = cont.size.x / get_parent().HAND_SIZE
	if hand.size() > get_parent().HAND_SIZE:
		interval = cont.size.x / hand.size()
	var j = index
	
	while j >= 0:
		var tween = create_tween()
		tween.parallel().tween_property(hand[j], "global_position", Vector2(x_pos - (j*interval), cont.position.y), .3)
		j -= 1
	
	return Vector2(x_pos, cont.position.y)

func remove_cards(cards):
	for card in cards:
		card.set_meta("last_position", card.global_position)
		card.play_animation("deselect")
		if card.selected.is_connected(_card_selected):
			card.selected.disconnect(_card_selected)
		if card.add_to_hand.is_connected(_card_added):
			card.add_to_hand.disconnect(_card_added)
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
		if wait_for_discard:
			emit_signal("discarded")
		
func _on_button_input_event(viewport, event, shape_idx, button_idx):
	# Clicked on button
	if event.is_action_pressed("click"):
		emit_signal("play_button_sound")
		match button_idx:
			0:
				_on_special_pressed()  

			1:
				_on_combo_pressed()
	
			2:
				_on_exchange_pressed()
		# Change button texture to pressed
		var button_node = ["Special", "Combo", "Exchange"][button_idx]
		get_node(button_node).get_node("ButtonSprite").texture = pressed_button_texture

func _on_button_mouse_entered(button_idx):
	# Hovered button
	var button_node = ["Special", "Combo", "Exchange"][button_idx]
	get_node(button_node).get_node("ButtonSprite").texture = focused_button_texture
	emit_signal("mouse_entered")

func _on_button_mouse_exited(button_idx):
	# Un - Hover button
	var button_node = ["Special", "Combo", "Exchange"][button_idx]
	get_node(button_node).get_node("ButtonSprite").texture = default_button_texture
	emit_signal("mouse_exited")
		
func _on_special_pressed():
	$SpecialTriggerDialog.popup_centered()

func _on_exchange_pressed():
	if focused_cards:
		emit_signal("exchange_cards")

func _on_combo_pressed():
	emit_signal("combo_cards")
	

func _on_special_action_dialog_id_pressed(id):
	match id:
		0: #"pick 1 from discards":
			emit_signal("pick_one_discard")
		1: #"get random full hand":
			emit_signal("replace_hand")
		2: #"switch cards with dealer":
			emit_signal("full_exchange")
		3: #"get gold card":
			emit_signal("get_gold_card")
	_on_button_mouse_exited(0)

func _on_special_trigger_dialog_id_pressed(id):
	var trigger = special_triggers[id]
	var validate_trigger=false 
	var error_message = ""
	match trigger:
		"joker":
			for card in hand:
				if card.title=="Joker":	
					focused_cards = [card]
					validate_trigger=true
			if !validate_trigger: error_message="no joker found in hand"
				
		"match 3":
			if focused_cards.size()==3:
				if ((focused_cards[0].title == focused_cards[1].title) && (
					focused_cards[1].title == focused_cards[2].title)):
					validate_trigger=true
				else: error_message = "these are not exact matches"
			else:
				error_message="choose 3 cards to match"
				
		"1 card hand":
			if hand.size()==1:
				focused_cards = hand.duplicate(true)
				validate_trigger = true
			else: error_message="more than one card in hand"
	
	if validate_trigger:
		emit_signal("discard", self)
		await discard_node.discard_over
		$SpecialActionDialog.set_item_text(0, special_actions[0]%[discard_node.cards.size()])
		$SpecialActionDialog.popup_centered()
	else:
		emit_signal("update_label", error_message)

# Draw token Methods

func update_draw_token_values():
	draw_token_values.clear()
	for token in draw_tokens:
		draw_token_values.append(token.get_meta("bonus"))

func add_draw_token(draw_token):
	draw_token.mouse_entered.connect(_on_token_mouse_entered.bind(draw_token))
	draw_token.mouse_exited.connect(_on_token_mouse_exited.bind(draw_token))
	draw_token.input_event.connect(_on_token_input_event.bind(draw_token))
	add_child(draw_token)
	draw_tokens.append(draw_token)
	var tween = create_tween()
	tween.tween_property(draw_token, "global_position", get_token_position(), 1).from(Globals.pixelframe.get_center())
	
	update_draw_token_values()
		
		
func use_draw_token(token):
	var bonus = token.get_meta("bonus")
	draw_tokens.erase(token)
	get_token_position()
	emit_signal("add_draw_bonus", bonus)
	token.call_deferred("queue_free")
	
	update_draw_token_values()
	
func get_token_position():
	var default_token_position = cont.position + cont.size
	default_token_position.y += 48
	var index = 0
	for token in draw_tokens:
		var target_x_position = default_token_position.x + (96*index)
		var tween = create_tween()
		tween.parallel().tween_property(token, "global_position:x", target_x_position, .2)
		index += 1
	return Vector2(default_token_position.x + 96*(index-1), default_token_position.y) 
	
	
func _on_token_mouse_entered(token):
	token.get_node("AnimatedSprite2D").play("highlight")
	emit_signal("mouse_entered")
	
func _on_token_mouse_exited(token):
	token.get_node("AnimatedSprite2D").play("default")
	emit_signal("mouse_exited")
	
func _on_token_input_event(viewport, event, shape_idx, token):
	if event.is_action_pressed("click"):
		
		use_draw_token(token)

