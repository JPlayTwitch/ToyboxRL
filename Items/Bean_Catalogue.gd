extends Node

onready var mess_log = get_node("/root/Game/MessageLog/MLogText")
onready var game = get_node("/root/Game/")
onready var InvUI = get_node("/root/Game/Inventory/Inventory")



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

func assign_beans():
	
	# set up the list for flavour selection
	var flavour_list = range(Flavours.size())
	bean_flavour.resize(Effects.size())
	bean_name_tasted.resize(Effects.size())
	bean_name_untasted.resize(Effects.size())
	tasted.resize(Effects.size())

	# create the bean types
	for i in range(Effects.size()):
		var flavour = randi() % flavour_list.size()
		bean_flavour[i] = flavour
		flavour_list.remove(flavour)
		bean_name_untasted[i] = "[color="+bean_colour[flavour]+"]Mysterious "+flavour_text[flavour]+" Jelly Bean[/color]"
		bean_name_tasted[i] = "[color="+bean_colour[flavour]+"]"+flavour_text[flavour]+" Jelly Bean of "+effects_text[i]+"[/color]"
		tasted[i] = false

func use_bean(effect_str):
	var effect = effects_text.find(effect_str)
	
	if tasted[effect]:
		mess_log.append_bbcode("\n You ate a "+bean_name_tasted[effect]+".")
	else:
		mess_log.append_bbcode("\n You ate a "+bean_name_untasted[effect]+".\n It must have been a "+bean_name_tasted[effect]+".")
		tasted[effect] = true
	match effect:
		Effects.BRAWN:
			mess_log.append_bbcode("\n You feel stronger.")
			PlayerStats.strength += 1
			game.update_visuals()
		Effects.ENDURANCE:
			mess_log.append_bbcode("\n You feel more resilient.")
			var hp_increase = int(PlayerStats.max_hp*0.2)
			PlayerStats.max_hp = PlayerStats.max_hp + hp_increase
			PlayerStats.hp = min(PlayerStats.hp + hp_increase,PlayerStats.max_hp)
			game.update_visuals()
		Effects.PERPLEXITY:
			mess_log.append_bbcode("\n You feel confused.")
			PlayerStats.confused += 20
			game.update_visuals()
		Effects.PARALYSIS:
			mess_log.append_bbcode("\n You are frozen in place. Press space to continue.")
			PlayerStats.paralysed = true
			InvUI.visible = false
			game.update_visuals()
		Effects.HEALING:
			mess_log.append_bbcode("\n You feel much better.")
			PlayerStats.hp = min(PlayerStats.hp+int(0.5*PlayerStats.max_hp),PlayerStats.max_hp)
			game.update_visuals()
		Effects.LITHENESS:
			mess_log.append_bbcode("\n You feel positively limber.")
			PlayerStats.evasion = min(PlayerStats.evasion+5, 90)
			game.update_visuals()
	InvDict.removeitem(effect_str)
