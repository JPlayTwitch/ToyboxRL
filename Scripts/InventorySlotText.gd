extends RichTextLabel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(int) var item_slot
var letters = ["a","b","c","d","e","f","g","h","i","j"]


# Called when the node enters the scene tree for the first time.
func _ready():
	InvDict.connect("inventory_changed", self, "on_inventory_changed")

# on signal from InvDict
func on_inventory_changed():
	if InvDict.inventory.size() > item_slot:
		var bean_str = InvDict.inventory.keys()[item_slot]
		var bean_type = BeanCatalogue.effects_text.find(bean_str)
		if BeanCatalogue.tasted[bean_type]:
			self.bbcode_text = letters[item_slot] + ") " + BeanCatalogue.bean_name_tasted[bean_type] + " (x" + str(InvDict.inventory[bean_str]) + ")"
		else:
			self.bbcode_text = letters[item_slot] + ") " + BeanCatalogue.bean_name_untasted[bean_type] + " (x" + str(InvDict.inventory[bean_str]) + ")"
	else:
		self.bbcode_text = ""
