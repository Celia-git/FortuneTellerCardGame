extends Control


var sub_game
var screen_shot

# Pixel world should only have one sub game at a time
# Multiple subgame controls happen in interior scenes

func set_sub_game(game):
	sub_game = game
	add_child(sub_game)
	# Scale all children of rigid bodies when they enter scene

func get_sub_game():
	return sub_game


func clear_current_sub_game():
	if sub_game in get_children():
		remove_child(sub_game)

