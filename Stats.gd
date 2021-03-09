extends Node

export(int) var max_hp = 20
onready var hp = max_hp setget set_hp
export(int) var dmg = 7
export(int) var weighting = 5

func set_hp(value):
	hp = value
