extends Node

enum Effects {BRAWN, ENDURANCE, PERPLEXITY, PARALYSIS, HEALING, LITHENESS}
enum Flavours {LICORICE, TANGERINE, STRAWBERRY, APPLE, BLUEBERRY, CAPPUCINO, WATERMELON, BUTTERSCOTCH, \
	BUBBLEGUM, COCONUT, MINT, GRAPE}

var flavour_text = ["Licorice", "Tangerine", "Strawberry", "Green Apple", "Blueberry", "Cappucino", "Watermelon", "Butterscotch", \
	"Bubblegum", "Coconut", "Mint", "Grape"]

var bean_colour = ["#464644", "#e68500", "#d80535", "#159341", "#0058a5", "#64371e", "#00562d", "#ddb889", \
	"#ecc4fa", "#cdddf7", "#a1d9f8", "#653494"]

var effects_text = ["Brawn", "Endurance", "Perplexity", "Paralysis", "Healing", "Litheness"]

var bean_flavour = []
var bean_name_tasted = []
var bean_name_untasted = []
var tasted = []
var effect = []

func assign_beans():
	
	# set up the list for flavour selection
	var flavour_list = range(Flavours.size())
	bean_flavour.resize(Effects.size())
	bean_name_tasted.resize(Effects.size())
	bean_name_untasted.resize(Effects.size())
	tasted.resize(Effects.size())
	effect.resize(Effects.size())

	# create the bean types
	for i in range(Effects.size()):
		var flavour = randi() % flavour_list.size()
		bean_flavour[i] = flavour
		flavour_list.remove(flavour)
		bean_name_untasted[i] = "[color="+bean_colour[flavour]+"]Mysterious "+flavour_text[flavour]+" Jelly Bean[/color]"
		bean_name_tasted[i] = "[color="+bean_colour[flavour]+"]"+flavour_text[flavour]+" Jelly Bean of "+effects_text[i]+"[/color]"
		tasted[i] = true
		effect[i] = effects_text[i]
