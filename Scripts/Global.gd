extends Node

var filepath = "res://config.ini"
var config_file

var keybinds = {}

var game_state = "standard"

var show_log = false

onready var music_bus := AudioServer.get_bus_index("Music")


# Called when the node enters the scene tree for the first time.
func _ready():
	config_file = ConfigFile.new()
	if config_file.load(filepath) == OK:
		for key in config_file.get_section_keys("keybinds"):
			var key_value = config_file.get_value("keybinds",key)
#			print(key," : ",OS.get_scancode_string(key_value))
			
			keybinds[key] = key_value
		var music_value = config_file.get_value("audio","Music")
		AudioServer.set_bus_volume_db(music_bus, linear2db(music_value))
	else:
		print("CONFIG FILE NOT FOUND")
		get_tree().quit()
	
	set_game_binds()

func set_game_binds():
	for key in keybinds.keys():
		var value = keybinds[key]
		
		var actionlist = InputMap.get_action_list(key)
		if !actionlist.empty():
			InputMap.action_erase_event(key,actionlist[0])
		
		var new_key = InputEventKey.new()
		new_key.set_scancode(value)
		InputMap.action_add_event(key,new_key)

func write_config():
	for key in keybinds.keys():
		var key_value = keybinds[key]
		config_file.set_value("keybinds", key, key_value)
	config_file.save(filepath)

func write_audio(audio_bus_name,key_value):
	config_file.set_value("audio",audio_bus_name,key_value)
	config_file.save(filepath)
