extends Sprite

#export onready var stats = $Stats

export(int) var max_hp = 30
onready var hp = max_hp
export(int) var attack_dice = 7
export(int) var strength = 2
export(int) var weighting = 4
export(int) var vision = 10
export(int) var evasion = 0
var dead = false
onready var mess_log = get_node("/root/Game/MessageLog/MLogText")


func act(game,me):
	if self.visible:
		if abs(me.tile.x-game.player_tile.x) < 2 && abs(me.tile.y-game.player_tile.y) < 2:
			var dmg = randi() % attack_dice + strength
			var hit = randi() % 100 >= PlayerStats.evasion
			if hit:
				mess_log.append_bbcode("\n [color=#4b4b4b]Drinking Bird[/color] dunked you for [color=#ff0000]" + str(dmg) + "[/color] damage")
				game.damage_player(dmg)
			else:
				mess_log.append_bbcode("\n [color=#4b4b4b]Drinking Bird[/color] bobbed inaccurately")
			me.sprite_node.frame = 1
			var t = Timer.new()
			t.set_wait_time(0.2)
			t.set_one_shot(true)
			self.add_child(t)
			t.start()
			yield(t, "timeout")
			t.queue_free()
			me.sprite_node.frame = 0

func take_damage(game,dmg):
	var hit = randi() % 100 >= evasion
	if hit:
		hp = max(0, hp-dmg)
		mess_log.append_bbcode("\n You hit [color=#4b4b4b]Drinking Bird[/color] for [color=#00ff00]" + str(dmg) + "[/color] damage")
		
		if hp == 0:
			mess_log.append_bbcode("\n [color=#4b4b4b]Drinking Bird[/color] died")
		if hp == 0:
			dead = true#
	else:
		mess_log.append_bbcode("\n You missed the [color=#4b4b4b]Drinking Bird[/color]")
