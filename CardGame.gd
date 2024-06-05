extends Node


signal add_player_inventory
signal add_player_tickets
signal display_text
signal update_prompt
signal update_matches
signal update_combo_streak
signal view_achievements
signal hide_achievements
signal new_tip
signal carry_over
signal carry_back
signal mouse_entered
signal mouse_exited
signal mute_sounds

const DECK_SIZE = 3
const HAND_SIZE = 7

var image_filename = "Cards.png"
@onready var deck = $Deck
@onready var deck_pos = deck.global_position
@onready var dealer = $Dealer
@onready var player = $Player
@onready var discard = $Discard
var achievements_popped_up = false

var match_path = "res://Match.tscn"
var draw_token_path = "res://DrawToken.tscn"
var draw_token_overlay_path = "res://resources/draw_token_{0}.tres"
var combo_tracker_path = "res://ComboTracker.gd"
var achievements_path = "res://Achievements.gd"
var left_arrow = "res://resources/LeftArrow.tres"
var right_arrow = "res://resources/RightArrow.tres"

# Current game stage (phase)
var stage
# Dictionary containing image names which correspond to match textures
var show_match_images = {}
# During draw phase, get 1 bonus card for a combo
# Add bonus cards for draw tokens used
var combo_bonus = 0
# Tracks combos, sets up multi-combo rewards
var combo_tracker
# Script that tracks meta achievements, known characters, determines if overall game is won, etc
var achievements

var game_states=Globals.game_states

@onready var button_sound = preload("res://Assets/ui_select1.wav")
@onready var combo_sound = preload("res://Assets/cards_combo.wav")
@onready var draw_sound = preload("res://Assets/cards_draw.wav")
@onready var pass_sound = preload("res://Assets/cards_pass.wav")
@onready var shuffle_sound = preload("res://Assets/cards_shuffle.wav")
@onready var tap_sound = preload("res://Assets/cards_tap.wav")
@onready var untap_sound = preload("res://Assets/cards_untap.wav")
@onready var achievement_sound = preload("res://Assets/achievement.wav")
@onready var coin_sound = preload("res://Assets/coin.wav")



func _ready():
	$ConfettiGenerator.set_confetti_type("diamonds")
	create_images()
	new_game()


func load_data():
	# Load Achievements
	$Deck.populate()
	achievements = load(achievements_path).new()

	if !achievements.win_game.is_connected(_win_game):
		achievements.win_game.connect(_win_game)
	if !achievements.achievement_unlocked.is_connected(_achievement_unlocked):
		achievements.achievement_unlocked.connect(_achievement_unlocked)
	if !achievements.load_images.is_connected(_load_achievement_images):
		achievements.load_images.connect(_load_achievement_images)
		
	if game_states.esther != null:
		achievements.load_data($Deck.get_types(), game_states.esther["known_characters"], game_states.esther["achievements"], game_states.esther["unlocked_achievements"])
	
	
func new_game():
	combo_tracker = load(combo_tracker_path).new()
	combo_tracker.combo_streak.connect(_new_combo_streak)
	combo_tracker.update_combo_progress.connect(_update_combo_progress)
	discard.max_pile_size = deck.cards.size()
	deal(0)
	

func deal(arg):
		
	stage = "draw"
	match arg:
		0:		# Deal for first turn
			# Initial deal: Distribute x-cards to player
			var place_on_board = 0
			while player.hand.size()<HAND_SIZE:
				player.add_card(deck.draw(), place_on_board, deck_pos)
				place_on_board += 1
			while dealer.hand.size()<HAND_SIZE:
				dealer.add_card(deck.draw(), place_on_board, deck_pos)
				place_on_board += 1
		1:		# Deal all other turns
				
			# Draw for player
			var amount = 1 + combo_bonus
			for i in amount:
				var new_card = deck.draw()
				if player.hand.size() <= HAND_SIZE:
					player.add_card(new_card, player.hand.size(), deck_pos)
				else:
					new_card.set_meta("last_position", deck.global_position)
					discard.add_cards([new_card])
			if combo_bonus > 0:
				emit_signal("update_prompt", "Draw Bonus:\n%d extra cards!"%[combo_bonus])
			
			combo_bonus=0
			
			# Draw for dealer
			var new_card = deck.draw()
			if dealer.hand.size() <= HAND_SIZE:
				dealer.add_card(new_card, dealer.hand.size(), deck_pos)
			else:
				new_card.set_meta("last_position", deck.global_position)
				discard.add_cards([new_card])

		2: 		# Deal player entire hand
			if deck.cards.size() < HAND_SIZE:
				await discard.delete_cards()
				deck.populate()
			while player.hand.size() <= HAND_SIZE:
				var new_card = deck.draw()
				player.add_card(new_card, player.hand.size(), deck_pos)
				
	stage = "action"
	emit_signal("update_prompt", player.labels[stage])
	

		
func _exchange_cards():
	
	if stage=="action":
		var dealer_cards = dealer.focused_cards
		var player_cards = player.focused_cards
		var dealer_value = 0
		var player_value = 0
		for card in dealer_cards:
			dealer_value += card.type["exchange_value"]
		for card in player_cards:
			player_value += card.type["exchange_value"]

		if (player_value == dealer_value):
			execute_exchange(player_cards, dealer_cards)
			emit_signal("update_prompt", "")
		else:
			emit_signal("update_prompt", player.labels["exchange_failed"])
			
		combo_tracker.track("", "", "")

func _combo_cards():
	
	if stage=="action":
		var cards = player.focused_cards
		var role = ""
		var age = ""
		var element = ""
		for card in cards:
			match card.type["type"]:
				"role":
					role = card.title
				"stage":
					age = card.title
				"element":
					element = card.title
		# Invalid combination
		if !(role and age and element) or cards.size()!=3:
			emit_signal("update_prompt", player.labels["bad_combo"])
			return
		
		var character = "%s %s %s" % [element, age, role]
		
		# Already known match
		if character in achievements.known_characters:
			emit_signal("update_prompt", player.labels["char_known"] + "\n" + character)
			return
		# Match found
		else:
			emit_signal("update_prompt", player.labels["new_combo"]+ "\n" + character)
			
			# Create new match sprites
			var sprite = get_character_sprites(element, age, role)
			sprite.add_to_group("matches")
			sprite.set_meta("character", character)
			add_child(sprite)
			emit_signal("carry_over", sprite, Globals.bigframe.get_center(), false)
			new_match_added(character)
			
		combo_tracker.track(element, age, role)
			


# Called after sending match to canvas
func new_match_added(character):
	
	$AudioStreamPlayer2D.set_stream(combo_sound)
	$AudioStreamPlayer2D.playing = true
	
	await add_to_discard(player)
	achievements.add_character(character)
	combo_bonus += 1
	
	emit_signal("update_matches")
	
	$ConfettiGenerator.start(Vector2(0, -1), 3, 200)
	achievements.check_win()
	achievements.check_achievements()
	resolve()
	

func resolve():
	stage = "resolve"
	# Player discard 
	if player.hand.size()>HAND_SIZE:	
		emit_signal("update_prompt", player.labels[stage])
		player.wait_for_discard = true
		await player.discarded

		await add_to_discard(player)

	# Dealer discard
	if dealer.hand.size()>HAND_SIZE:
		dealer.focused_cards.clear()
		dealer.focused_cards.append(dealer.get_random_card())
		await add_to_discard(dealer)
		
	if (player.hand.size() > HAND_SIZE && dealer.hand.size() > HAND_SIZE):
		stage="action"
	else:	stage = "upkeep"
	emit_signal("update_prompt", player.labels[stage])
	
	

func _draw():
	if stage=="upkeep":
		
		player.untap()
		dealer.untap()
		deal(1)
			
# Remove all cards from discard and shuffle a new deck
func _reshuffle_deck():
	await discard.delete_cards()
	deck.populate()
			
func add_to_discard(from_hand):
	await from_hand.remove_cards(from_hand.focused_cards)
	await discard.add_cards(from_hand.focused_cards)
	await discard.discard_over
	from_hand.focused_cards.clear()
	
func execute_exchange(player_cards, dealer_cards):
		# Execute exchange
	await player.remove_cards(player_cards)
	await dealer.remove_cards(dealer_cards)
	for card in player_cards:
		dealer.add_card(card, dealer.hand.size(), card.get_meta("last_position"))
	player.focused_cards.clear()
	for card in dealer_cards:
		player.add_card(card, player.hand.size(), card.get_meta("last_position"))
	dealer.focused_cards.clear()
	await get_tree().create_timer(.5).timeout
	resolve()
	

	
func _win_game():
	emit_signal("update_prompt", "All matches found!")


func _achievement_unlocked(type):
	$ConfettiGenerator.start(Vector2(0, -1), 3, 400)
	emit_signal("new_tip", "Achievement unlocked!\nAll %ss are found!" % [type])
	await get_tree().create_timer(1).timeout
	emit_signal("view_achievements")
	$AudioStreamPlayer2D.set_stream(achievement_sound)
	$AudioStreamPlayer2D.playing = true
	achievements_popped_up = true

func create_images():
	if !show_match_images.is_empty():
		return
	var textures = Globals.texture_script.new()
	var item_data = textures.get_image_data(image_filename)
	for item in item_data.keys():
		var item_atlas = (textures.get_atlas(image_filename,item, item_data[item])[0])
		
		# Load card game related sprites
		if item.begins_with("Card"):
			var item_name = item.trim_prefix("Card")
			player.images[item_name] = item_atlas
			discard.images[item_name] = item_atlas
		elif item == ("TableDeck"):
			deck.set_image(textures.get_atlas(image_filename, item, item_data[item])[0])
		elif item == ("DeckTopCard"):
			deck.set_top_card(textures.get_atlas(image_filename, item, item_data[item])[0])
		elif item == ("TableCards"):
			var images = textures.get_atlas(image_filename, item, item_data[item])
			dealer.set_images(images)
		# Load collection of character images
		else:
			show_match_images[item] = item_atlas
			
# If there are known characters, automatically add them to the canvas layer
func load_character_matches():
	create_images()
	if !achievements.known_characters.is_empty():
		for chr in achievements.known_characters:
			var character = chr.split(" ")
			var sprite = get_character_sprites(character[0], character[1], character[2])
			sprite.add_to_group("matches")
			sprite.set_meta("character", chr)
			add_child(sprite)
			emit_signal("carry_over", sprite, Globals.bigframe.get_center(), false)
				
	emit_signal("update_matches")
			
# Return 2D Node associated with this character's sprites
func get_character_sprites(element, stage, role):
	
	var new_match = load(match_path).instantiate()
	
	new_match.get_node("Layer0").texture = show_match_images[element]
	new_match.get_node("Layer1").texture = show_match_images[stage]
	new_match.get_node("Layer2").texture = show_match_images[role]
	
	return new_match

func _replace_hand():
	player.focused_cards.clear()
	for card in player.hand:
		player.focused_cards.append(card)
	player.remove_cards(player.focused_cards)
	player.focused_cards.clear()
	deal(2)
	
# Player and dealer swap hands
func _full_exchange():
	player.focused_cards.clear()
	dealer.focused_cards.clear()
	for card in player.hand:
		player.focused_cards.append(card)
	for card in dealer.hand:
		dealer.focused_cards.append(card)
	execute_exchange(player.focused_cards, dealer.focused_cards)

# new streak; reward draw tokens
func _new_combo_streak(streak_type, value, amount):
	emit_signal("new_tip", "New %s combo streak! \n%d %s combos in a row!" % [streak_type, amount, value])
	$AudioStreamPlayer2D.set_stream(coin_sound)
	$AudioStreamPlayer2D.playing = true
	match streak_type:
		"element":
			_get_draw_token(1)
			_get_gold_card()
		"stage":
			_get_draw_token(2)
		"role":
			_get_draw_token(4)
			
# Update visuals associated with tracking combo streaks
func _update_combo_progress(combo_data):
	var progress_icons = [[],[],[]]
	var types = combo_data.keys()
	
	# Create progress icons (texture 2d nodes)
	for i in range(types.size()): 
		var type = types[i]
		if combo_data[type] > 0:
			var total_icons = 2+i
			var streak = total_icons - combo_data[type]

			# All icons not in streak are shadowed out
			for j in range(total_icons):
				var atlas = show_match_images[type]
				var texture = TextureRect.new()
				texture.set_stretch_mode(4)
				texture.texture = atlas
				texture.self_modulate = Color(1, 1, 1, 1)
				progress_icons[i].append(texture)

			for h in range(streak):
				progress_icons[i][total_icons-h-1].self_modulate = Color(0, 0, 0, 1)
		
	emit_signal("update_combo_streak", progress_icons)
	
# Reward player with a gold card
func _get_gold_card():
	var card_found = false
	var temp_cards = []
	var card_count = deck.cards.size()
	while (card_count > 0 && !card_found):
		var card = deck.draw()
		if card.type["type"]=="element":
			player.add_card(card, player.hand.size(), deck_pos)
			card_found = true
		else:
			temp_cards.append(card)
	if !card_found:
		discard.get_cards()
	deck.replace(temp_cards)
			
# Reward player with a draw token
func _get_draw_token(arg):
	$AudioStreamPlayer2D.set_stream(coin_sound)
	$AudioStreamPlayer2D.playing = true
	var draw_token = load(draw_token_path).instantiate()
	var draw_token_overlay = load(draw_token_overlay_path.format([str(arg)]))
	draw_token.get_node("Sprite2D").texture = draw_token_overlay
	draw_token.set_meta("bonus", arg)
	$Player.add_draw_token(draw_token)
	achievements.draw_token_values = $Player.draw_token_values
	
func _add_draw_bonus(arg):
	emit_signal("new_tip", "New draw bonus! \n\t+ %d card" % [arg])
	combo_bonus += arg
	achievements.draw_token_values = $Player.draw_token_values
			
func _on_player_discarded():
	pass # Replace with function body.



func _on_discard_over():
	pass # Replace with function body.



func dialog_finished():
	pass

func _play_button_sound():
	$AudioStreamPlayer2D.set_stream(button_sound)
	$AudioStreamPlayer2D.playing = true

func _play_shuffle_sound():
	$AudioStreamPlayer2D.set_stream(shuffle_sound)
	$AudioStreamPlayer2D.playing = true
	
func _play_draw_sound():
	$AudioStreamPlayer2D.set_stream(draw_sound)
	$AudioStreamPlayer2D.playing = true

func _on_player_update_label(text):
	emit_signal("update_prompt", text)


func _on_tree_exiting():
	emit_signal("update_prompt", "")

func _mouse_entered():
	emit_signal("mouse_entered")
	
func _mouse_exited():
	emit_signal("mouse_exited")





func _on_discard_update_label():
	emit_signal("update_prompt", "")


func _on_achievements_tab_mouse_entered():
	$AchievementsTab/Sprite2D.flip_h = achievements_popped_up
	$AchievementsTab/Sprite2D.visible = true
	_mouse_entered()

func _on_achievements_tab_mouse_exited():
	$AchievementsTab/Sprite2D.visible = false
	_mouse_exited()

func _on_achievements_tab_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click"):
		if !achievements_popped_up:				
			emit_signal("view_achievements")
			$AchievementsTab/Sprite2D.texture = load(left_arrow)
			achievements_popped_up = !achievements_popped_up

	
func close_achievements():	
	emit_signal("hide_achievements")
	$AchievementsTab/Sprite2D.texture = load(right_arrow)
	achievements_popped_up = !achievements_popped_up


func _on_player_ready():
	if game_states.esther != null:
		var array = game_states.esther["draw_tokens"]
		for entry in array:	
			_get_draw_token(entry)
		$Player.draw_token_values = game_states.esther["draw_tokens"]

func _load_achievement_images(atlas, nam):
	
	# Creaete new Texture rect with atlas image, set basic variables
	var texture = TextureRect.new()
	texture.texture = atlas
	texture.set_meta("name", nam) 
	texture.add_to_group("achievements")
	
	# Create and style tooltip
	texture.tooltip_text = nam
	
	emit_signal("carry_over", texture, Vector2(0,0))


func _mute_sounds(mute):
	$AudioStreamPlayer2D.volume_db = [0, -80][int(mute)]
	emit_signal("mute_sounds", mute)

func save_game():
	achievements.save_game()
