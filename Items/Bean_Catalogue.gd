extends Node

enum BeanEffects {BRAWN, ENDURANCE, PERPLEXITY, PARALYSIS, HEALING, LITHENESS}
enum Flavours {LICORICE, TANGERINE, STRAWBERRY, APPLE, BLUEBERRY, CAPPUCINO, WATERMELON, BUTTERSCOTCH, \
	BUBBLEGUM, COCONUT, MINT, GRAPE}

var flavour_text = ["Licorice", "Tangerine", "Strawberry", "Green Apple", "Blueberry", "Cappucino", "Watermelon", "Butterscotch", \
	"Bubblegum", "Coconut", "Mint", "Grape"]

var bean_colour = ["#464644", "#e68500", "#d80535", "#159341", "#0058a5", "#64371e", "#00562d", "#ddb889", \
	"#ecc4fa", "#cdddf7", "#a1d9f8", "#653494"]

var bean_brawn_flavour = 0
var bean_brawn_name_tasted
var bean_brawn_name_untasted


func assign_beans():
	
	#For testing purposes only
#	randomize()
	
	# set up the list for flavour selection
	var flavour_list = range(Flavours.size())

	# create a bean - brawn
	var flavour = randi() % flavour_list.size()
	bean_brawn_flavour = flavour
	flavour_list.remove(flavour)
	bean_brawn_name_tasted = "[color="+bean_colour[flavour]+"]"+flavour_text[flavour]+" Jelly Bean of Brawn[/color]"
	bean_brawn_name_untasted = "[color="+bean_colour[flavour]+"]Mysterious "+flavour_text[flavour]+" Jelly Bean[/color]"
