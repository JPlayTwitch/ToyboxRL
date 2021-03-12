extends CanvasLayer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	BeanCatalogue.connect("MLogAppend",self,"_on_MLogAppend")
	pass # Replace with function body.

func _on_MLogAppend(msg):
	$MLogText.append_bbcode(msg)
	pass
