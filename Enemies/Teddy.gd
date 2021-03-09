extends Sprite

#export onready var stats = $Stats

export(int) var max_hp = 20
onready var hp = max_hp
export(int) var dmg = 3
export(int) var weighting = 2
export(int) var vision = 10
export(int) var evasion = 5
