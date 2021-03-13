extends CanvasLayer

var AudioMixer = preload("res://UI/AudioMixer.tscn")
var mixer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_TextureButton_toggled(button_pressed):
	if button_pressed:
		self.add_child(AudioMixer.instance())
	else:
		$AudioMixer.queue_free()
	$AudioButton.release_focus()
