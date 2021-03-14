extends VSlider

export var audio_bus_name := "Music"

onready var _bus := AudioServer.get_bus_index(audio_bus_name)


func _ready() -> void:
	value = db2linear(AudioServer.get_bus_volume_db(_bus))
#	self.connect("mouse_exited",self,release_focus())


func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(_bus, linear2db(value))
	Global.write_audio(audio_bus_name,value)


func _on_mouse_exited():
	self.release_focus()
