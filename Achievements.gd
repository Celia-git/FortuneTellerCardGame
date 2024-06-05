extends Node

signal win_game
signal achievement_unlocked
signal load_images

const ACHIEVEMENT_SIZE = Vector2(45, 45)
var known_characters = []
var unlocked_achievements = []
var card_types = {} # A dict of card types, organized by subcategory
var draw_token_values = []

var achievements = {
	"Fire":0,
	"Water":0,
	"Stone":0,
	"Maiden":0,
	"Mother":0,
	"Crone":0,
	"Spectre":0,
	"Warrior":0,
	"Mage":0,
	"Rogue":0,
	"Priest":0,
	"Seer":0,
	"Mother Warrior":0,
	"Spectre Rogue":0,
	"Maiden Priest":0,
	"Crone Seer":0,
	"Water Mage":0,
	"Fire Warrior":0,
	"Stone Priest":0,
	"Stone Spectre":0,
	"All Combos":0
	}
	
var goals = {
	"Fire":20,
	"Water":20,
	"Stone":20,
	"Maiden":15,
	"Mother":15,
	"Crone":15,
	"Spectre":15,
	"Warrior":12,
	"Mage":12,
	"Rogue":12,
	"Priest":12,
	"Seer":12,
	"Mother Warrior":3,
	"Spectre Rogue":3,
	"Maiden Priest":3,
	"Crone Seer":3,
	"Water Mage":4,
	"Fire Warrior":4,
	"Stone Priest":4,
	"Stone Spectre":5,
	"All Combos":1
	}
	
#Track achievements and known characters for saving 

# Set variables, load images
func load_data(types, known_char, achieve, unlocked_ach):
	achievements = achieve
	known_characters=known_char
	unlocked_achievements=unlocked_ach
	
	for subtype in types:
		card_types[subtype] = subtype["subcategories"]
	
	# Populate achievement goals dict, load achievement textures
	# Load custom achievement icons
	var textures = Globals.texture_script.new()
	var keys = goals.keys()
	var last_pos = Vector2(0, 0)
	for key in keys:
		
		var atlas = textures.get_atlas_all_args("achievements.png", last_pos, ACHIEVEMENT_SIZE)
		emit_signal("load_images", atlas, key)
		
		if key == "Stone":
			last_pos = Vector2(0, 1)
		elif key == "Spectre":
			last_pos = Vector2(0, 2)
		elif key == "Spectre Rogue":
			last_pos = Vector2(0, 3)
		else:
			last_pos.x += 1


##################### FINISH ################################
# Check for win condition (60 matches) or other achievements
func check_win():
	var match_amount = 1
	for subtype in card_types:
		match_amount *= subtype.size()
	if match_amount == known_characters.size():
		emit_signal("achievement_unlocked", "All Combos")
		unlocked_achievements.append("All Combos")
		emit_signal("win_game")
	

func check_achievements():
	
	for type in achievements:
		if !(type in goals.keys()):
			continue

		if (achievements[type] == goals[type]) and !(type in unlocked_achievements):
			
			unlocked_achievements.append(type)
			emit_signal("achievement_unlocked", type)
			
		
	
	
func add_character(character):
	var array = character.split(" ")
	# Check for standard 1-type achievement
	for item in array:
		if !(item in unlocked_achievements):
			if !(item in achievements.keys()):
				achievements[item]=1
			else:
				achievements[item] += 1
	
	# Check for custom 2-type achievements
	var scenario_1 = array[0] + " " + array[1]
	var scenario_2 = array[1] + " " + array[2]
	var scenario_3 = array[0] + " " + array[2]
	
	for scenario in [scenario_1, scenario_2, scenario_3]:
		if scenario in achievements.keys():
			achievements[scenario] += 1
			
	known_characters.append(character)

func save_game():
	Globals.game_states.esther["known_characters"] = known_characters
	Globals.game_states.esther["achievements"] = achievements
	Globals.game_states.esther["unlocked_achievements"] = unlocked_achievements
	Globals.game_states.esther["draw_tokens"] = draw_token_values

func rearrange_characters(new_order):
	known_characters = new_order
