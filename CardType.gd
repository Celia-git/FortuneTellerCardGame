extends Node

class_name CardType


var roles = {
	"type":"role", 
	"subcategories":["Warrior", "Mage", "Rogue", "Priest", "Seer"],
	"weight": 1.5,
	"color": Color.DARK_BLUE, 
	"exchange_value":1
}

var stages = {
	"type":"stage",
	"subcategories":["Maiden", "Mother", "Crone", "Spectre"],
	"weight":1.5,
	"color":Color.DARK_MAGENTA,
	"exchange_value":2
}

var elements = {
	"type":"element",
	"subcategories":["Fire", "Water", "Stone"],
	"weight":1,
	"color":Color.GOLDENROD,
	"exchange_value":4
}

var joker = {
	"type":"wildcard",
	"subcategories":["Joker"],
	"weight":0,
	"color":Color.AQUA,
	"exchange_value":4
} 

func get_joker():
	return joker

func get_types():
	return [roles, stages, elements]

