extends ColorRect

onready var Player = get_node("/root/Game/Player")
onready var mess_log = get_node("/root/Game/MessageLog/MLogText")

var bean_dict # bean dictionary position
var bean_str # bean string
var bean_type # bean actual type


# Called when the node enters the scene tree for the first time.
func _ready():
	$EatLabel.text = OS.get_scancode_string(Global.keybinds["Eat"]) + ": Eat"
	$ThrowLabel.text = OS.get_scancode_string(Global.keybinds["Throw"]) + ": Throw"
	$CancelLabel.text = OS.get_scancode_string(Global.keybinds["ui_cancel"]) + ": Cancel"
	Player.connect("select_bean",self,"select_bean")
#
func select_bean(bean):
	bean_dict = bean
	bean_str = InvDict.inventory.keys()[bean]
	bean_type = BeanCatalogue.effects_text.find(bean_str)
	if BeanCatalogue.tasted[bean_type]:
		$BeanLabel.bbcode_text = BeanCatalogue.bean_name_tasted[bean_type]
	else:
		$BeanLabel.bbcode_text = BeanCatalogue.bean_name_untasted[bean_type]
	$BeanSprite.frame = BeanCatalogue.bean_flavour[bean_type]

func _process(delta):
	if Global.game_state == "bean":
		self.visible = true
#	else:
#		self.visible = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if !event.is_pressed():
		return
	if self.visible:
		if event.is_action("Eat"):
			BeanCatalogue.use_bean(InvDict.inventory.keys()[bean_dict],get_node("/root/Game/"))
			Global.game_state = "standard"
			self.visible = false
		if event.is_action("ui_cancel"):
			Global.game_state = "standard"
			self.visible = false
		if event.is_action("Throw"):
			mess_log.append_bbcode("\n Press a direction to throw the currently selected bean")
			Global.game_state = "throwing"
			self.visible = false
			get_node("..").visible = false
#		elif event.is_action("ui_cancel"):
#			Global.game_state == "standard"
#			self.visible = false
