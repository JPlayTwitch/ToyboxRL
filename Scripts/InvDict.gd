extends Reference


var inventory = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func add(key):
	if inventory.has(key):
		inventory[key] += 1
	else:
		inventory.key = 1
	
func remove(key):
	if inventory.has(key):
		inventory[key] -= 1
		if inventory[key] < 1:
			inventory.erase(key)
