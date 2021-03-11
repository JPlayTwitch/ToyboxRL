extends Node


var inventory = {}
signal inventory_changed
# Called when the node enters the scene tree for the first time.
func _ready():
	emit_signal("inventory_changed")


func additem(key):
	if inventory.has(key):
		inventory[key] += 1
	else:
		inventory[key] = 1
	emit_signal("inventory_changed")
	
func removeitem(key):
	if inventory.has(key):
		inventory[key] -= 1
		if inventory[key] < 1:
			inventory.erase(key)
	emit_signal("inventory_changed")
