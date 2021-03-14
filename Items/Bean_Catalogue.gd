extends Node

signal MLogAppend

var mess_log = MessageLog.get_node("MLogText")
signal CloseInv
signal turn_advance



enum Effects {BRAWN, ENDURANCE, PERPLEXITY, PARALYSIS, HEALING, LITHENESS, ENFEEBLEMENT}
enum Flavours {LICORICE, TANGERINE, STRAWBERRY, APPLE, BLUEBERRY, CAPPUCINO, WATERMELON, BUTTERSCOTCH, \
	BUBBLEGUM, COCONUT, MINT, GRAPE}

var flavour_text = ["Licorice", "Tangerine", "Strawberry", "Green Apple", "Blueberry", "Cappucino", "Watermelon", "Butterscotch", \
	"Bubblegum", "Coconut", "Mint", "Grape"]

var bean_colour = ["#464644", "#e68500", "#d80535", "#159341", "#0058a5", "#64371e", "#00562d", "#ddb889", \
	"#ecc4fa", "#cdddf7", "#a1d9f8", "#653494"]

var effects_text = ["Brawn", "Endurance", "Perplexity", "Paralysis", "Healing", "Litheness", "Enfeeblement"]

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
		var flavour = flavour_list[randi() % flavour_list.size()]
		bean_flavour[i] = flavour
		flavour_list.erase(flavour)
		bean_name_untasted[i] = "[color="+bean_colour[flavour]+"]Mysterious "+flavour_text[flavour]+" Jelly Bean[/color]"
		bean_name_tasted[i] = "[color="+bean_colour[flavour]+"]"+flavour_text[flavour]+" Jelly Bean of "+effects_text[i]+"[/color]"
		tasted[i] = false

func use_bean(effect_str,game):
	var effect = effects_text.find(effect_str)
	
	if tasted[effect]:
		emit_signal("MLogAppend","\n You ate a "+bean_name_tasted[effect]+".")
	else:
		emit_signal("MLogAppend","\n You ate a "+bean_name_untasted[effect]+".\n It must have been a "+bean_name_tasted[effect]+".")
		tasted[effect] = true
#	print("should be working")
	match effect:
		Effects.BRAWN:
			emit_signal("MLogAppend","\n You feel stronger.")
			PlayerStats.strength += 2
			game.update_visuals()
		Effects.ENDURANCE:
			emit_signal("MLogAppend","\n You feel more resilient.")
			var hp_increase = int(PlayerStats.max_hp*0.2)
			PlayerStats.max_hp = PlayerStats.max_hp + hp_increase
			PlayerStats.hp = min(PlayerStats.hp + hp_increase,PlayerStats.max_hp)
			game.update_visuals()
		Effects.PERPLEXITY:
			emit_signal("MLogAppend","\n You feel confused.")
			PlayerStats.confused += 20
			game.update_visuals()
		Effects.PARALYSIS:
			emit_signal("MLogAppend","\n You are frozen in place. Press space to continue.")
			PlayerStats.paralysed = true
			emit_signal("CloseInv")
			game.update_visuals()
		Effects.HEALING:
			emit_signal("MLogAppend","\n You feel much better.")
			PlayerStats.hp = min(PlayerStats.hp+int(0.5*PlayerStats.max_hp),PlayerStats.max_hp)
			game.update_visuals()
		Effects.LITHENESS:
			emit_signal("MLogAppend","\n You feel positively limber.")
			PlayerStats.evasion = min(PlayerStats.evasion+5, 90)
			game.update_visuals()
		Effects.ENFEEBLEMENT:
			emit_signal("MLogAppend","\n Everything feels a little more difficult.")
			PlayerStats.strength -= 2
			game.update_visuals()
	InvDict.removeitem(effect_str)
	emit_signal("turn_advance")
