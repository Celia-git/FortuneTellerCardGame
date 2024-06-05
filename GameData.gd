extends Resource

class_name GameData

# Game states are loaded and saved each time the main scene changes.
# These changes are committed to file when the game is saved

@export var claw_machine = {"plushies_taken":[], "capsules_taken":[], "toys_taken":[], "treasure_taken":false}
@export var ducks = {"rounds_won":0, "record_time":0.0, "matches":[]}
@export var esther = {"known_characters":[], "achievements":{"Fire":0,"Water":0,
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
	"All Combos":0}, "unlocked_achievements":[], "draw_tokens":[]}
@export var games = {}
@export var ice_cream = {"orders_fulfilled":0, "orders_failed":0}
@export var popper = {}
				# "name" unlocked:bool, favor:int, quest:int
@export var customers = {"name":[true, 5, 2]}
@export var constellations = {}
@export var ext_map_data = {"hidden_prizes_unlocked":[], "active_quest":[], "completed_quests":[]}
