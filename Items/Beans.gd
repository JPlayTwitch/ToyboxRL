extends Sprite

enum BeanEffects {BRAWN, ENDURANCE, PERPLEXITY, PARALYSIS, HEALING, LITHENESS}
enum Flavours {LICORICE, TANGERINE, STRAWBERRY, APPLE, BLUEBERRY, CAPPUCINO, WATERMELON, BUTTERSCOTCH, \
	BUBBLEGUM, COCONUT, MINT, GRAPE}

var flavour_text = ["Licorice", "Tangerine", "Strawberry", "Apple", "Blueberry", "Cappucino", "Watermelon", "Butterscotch", \
	"Bubblegum", "Coconut", "Mint", "Grape"]

var bean_colour = ["#464644", "#e68500", "#d80535", "#159341", "#0058a5", "#64371e", "#00562d", "#ddb889", \
	"#ecc4fa", "#cdddf7", "#a1d9f8", "#653494"]

class Bean extends Reference:
	var tasted = false
	var name_untasted
	var name_tasted
	var flavour




func _init():
	
	#For testing purposes only
	randomize()
	
	# set up the list for flavour selection
	var flavour_list = range(Flavours.size())

	# create a bean - brawn
	var Bean_Brawn = Bean.new()
	var flavour = randi() % flavour_list.size()
	Bean_Brawn.flavour = flavour
	flavour_list.remove(flavour)
	Bean_Brawn.name_tasted = "[color="+bean_colour[flavour]+"]"+flavour_text[flavour]+" Jelly Bean of Brawn[/color]"
	Bean_Brawn.name_untasted = "[color="+bean_colour[flavour]+"]Mysterious "+flavour_text[flavour]+" Jelly Bean[/color]"
	print(Bean_Brawn.name_tasted)
	print(Bean_Brawn.name_untasted)




# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
