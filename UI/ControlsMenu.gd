extends Node

var keybinds
onready var buttons = get_tree().get_nodes_in_group("Keybind_Buttons")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	keybinds = Global.keybinds.duplicate()
	
	$UpLeft.text = OS.get_scancode_string(keybinds["UpLeft"])
	$Up.text = OS.get_scancode_string(keybinds["Up"])
	$UpRight.text = OS.get_scancode_string(keybinds["UpRight"])
	$Left.text = OS.get_scancode_string(keybinds["Left"])
	$Right.text = OS.get_scancode_string(keybinds["Right"])
	$DownLeft.text = OS.get_scancode_string(keybinds["DownLeft"])
	$Down.text = OS.get_scancode_string(keybinds["Down"])
	$DownRight.text = OS.get_scancode_string(keybinds["DownRight"])
	$Wait.text = OS.get_scancode_string(keybinds["Wait"])
	$Accept.text = OS.get_scancode_string(keybinds["ui_accept"])
	$Inventory.text = OS.get_scancode_string(keybinds["Inventory"])
	$Eat.text = OS.get_scancode_string(keybinds["Eat"])
	$Throw.text = OS.get_scancode_string(keybinds["Throw"])
	$Cancel.text = OS.get_scancode_string(keybinds["ui_cancel"])


func change_bind(key,value):
	keybinds[key] = value
	


func _on_Undo_Changes_pressed():
	queue_free()


func _on_Save_Changes_pressed():
	Global.keybinds = keybinds.duplicate()
	Global.set_game_binds()
	Global.write_config()
	queue_free()
	pass # Replace with function body.
