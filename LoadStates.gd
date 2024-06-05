extends Node

signal save_finished

var save_signal_emitted = false


var setting = "res://MadameEstherInt.tscn"
	
	
# Keep track of which data has been saved
var terminate_next = false
var game_data_saved = false



func new_game():
	return load(Globals.game_script).new()


	
func load_game_data():
	game_data_saved = false
	
	var file_path = Globals.user_directory + Globals.game_file
	if ResourceLoader.exists(file_path):
		var load_data = ResourceLoader.load(file_path)
		if load_data is GameData: # Check that the data is valid
			if load_data.esther != null: 
				return load_data
		
	# if Data is corrupted or file is missing, load new game data
	return new_game()

	

# Return filepath of active scene
func get_setting(active_map:int, map_type:String):
		
	var main = load(setting).instantiate()
	main.setting_index = active_map
	return main
	


# Save data to file at quit

func save_game_data(data):
	var file_path = Globals.user_directory + Globals.game_file
	var result = ResourceSaver.save(data, file_path)
	assert(result == OK)
	game_data_saved=true
	check_saves()
	

		
# Check if save is finished, emit signal if so
func check_saves():
	if (game_data_saved && !save_signal_emitted):
		emit_signal("save_finished", terminate_next)
		save_signal_emitted=true
