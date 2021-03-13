extends Button

export(int) var value
export(String) var key
onready var menu = get_parent()

var waiting_input = false 
# Called when the node enters the scene tree for the first time.
func _ready():
	value = Global.keybinds[key]

func _input(event):
	if waiting_input:
		if event is InputEventKey:
			value = event.scancode
			text = OS.get_scancode_string(value)
			pressed = false
			waiting_input = false
			menu.change_bind(key,value)
		if event is InputEventMouseButton:
			text = OS.get_scancode_string(value)
			pressed = false
			waiting_input = false

func _toggled(button_pressed):
	if button_pressed:
		waiting_input = true
		set_text("Key?")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
