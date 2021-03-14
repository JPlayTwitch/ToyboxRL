extends Node

var filepath = "res://keybinds.ini"
var config_file

var keybinds = {}

var game_state = "standard"

var show_log = false


# Called when the node enters the scene tree for the first time.
func _ready():
	config_file = ConfigFile.new()
	if config_file.load(filepath) == OK:
		for key in config_file.get_section_keys("keybinds"):
			var key_value = config_file.get_value("keybinds",key)
#			print(key," : ",OS.get_scancode_string(key_value))
			
			keybinds[key] = key_value
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
