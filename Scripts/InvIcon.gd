extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(int) var item_slot

# Called when the node enters the scene tree for the first time.
func _ready():
	InvDict.connect("inventory_changed", self, "on_inventory_changed")


# on signal from InvDict
func on_inventory_changed():
	if InvDict.inventory.size() > item_slot:
		var bean_str = InvDict.inventory.keys()[item_slot]
		var bean_type = BeanCatalogue.effects_text.find(bean_str)
		self.frame = BeanCatalogue.bean_flavour[bean_type]
		self.visible = true
	else:
		self.visible = false
