extends Node2D

var CtrlsMenu = preload("res://UI/ControlsMenu.tscn")
var CreditsScreen = preload("res://UI/CreditsScreen.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_NewGame_pressed():
	MessageLog.get_node("MLogText").bbcode_text = "New Game \n \n \n"
#	$"CanvasLayer/New Game".pressed = false
	get_tree().change_scene("res://Scripts/Game.tscn")
	pass # Replace with function body.


func _on_Controls_pressed():
	$CanvasLayer.add_child(CtrlsMenu.instance())


func _on_Credits_pressed():
	$CanvasLayer.add_child(CreditsScreen.instance())
