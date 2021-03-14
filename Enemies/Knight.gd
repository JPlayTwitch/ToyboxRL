extends Sprite

#export onready var stats = $Stats

export(int) var max_hp = 30
onready var hp = max_hp
export(int) var attack_dice = 5
export(int) var strength = 4
export(int) var weighting = 7
export(int) var vision = 10
export(int) var evasion = 0
var dead = false
onready var mess_log = get_node("/root/Game/MessageLog/MLogText")
var type = "Knight"


func act(game,me):
	if self.visible:
		if (int(abs(me.tile.x - game.player_tile.x)) == 2 && int(abs(me.tile.y - game.player_tile.y)) == 1) || \
			(int(abs(me.tile.x - game.player_tile.x)) == 1 && int(abs(me.tile.y - game.player_tile.y)) == 2):
				print("attack")
				var dmg = randi() % attack_dice + strength
#				var hit = randi() % 100 >= PlayerStats.evasion
				# Knights ignore evasion
				var hit = true
				if hit:
					mess_log.append_bbcode("\n [color=#ffffb4]Knight[/color] chessed at you for [color=#ff0000]" + str(dmg) + "[/color] damage")
					game.damage_player(dmg)
				else:
					mess_log.append_bbcode("\n [color=#ffffb4]Knight[/color] swiped the air fruitlessly")
				me.sprite_node.frame = 1
				var t = Timer.new()
				t.set_wait_time(0.2)
				t.set_one_shot(true)
				self.add_child(t)
				t.start()
				yield(t, "timeout")
				t.queue_free()
				me.sprite_node.frame = 0
		else:
			var move_dir = randi() % 8
			var move_tile_x
			var move_tile_y
			match move_dir:
				0:
					move_tile_x = me.tile.x - 2
					move_tile_y = me.tile.y - 1
				1:
					move_tile_x = me.tile.x+2
					move_tile_y = me.tile.y-1
				2:
					move_tile_x = me.tile.x - 2
					move_tile_y = me.tile.y + 1
				3:
					move_tile_x = me.tile.x+2
					move_tile_y = me.tile.y+1
				4:
					move_tile_x = me.tile.x - 1
					move_tile_y = me.tile.y - 2
				5:
					move_tile_x = me.tile.x+1
					move_tile_y = me.tile.y-2
				6:
					move_tile_x = me.tile.x - 1
					move_tile_y = me.tile.y + 2
				7:
					move_tile_x = me.tile.x+1
					move_tile_y = me.tile.y+2
			if move_tile_x > 0 && move_tile_y > 0 && move_tile_x < game.map.size() && move_tile_y < game.map[1].size():
				var blocked = false
				if game.map[move_tile_x][move_tile_y] != game.tile_floor:
					blocked = true
				if game.floor_type[move_tile_x][move_tile_y] != game.FloorType.Chess:
					blocked = true
				for enemy in game.enemies:
					if enemy.tile.x == move_tile_x && enemy.tile.y == move_tile_y:
						blocked = true
						break
				if !blocked:
					me.tile.x = move_tile_x
					me.tile.y = move_tile_y

func take_damage(game,dmg):
	var hit = randi() % 100 >= evasion
	if hit:
		hp = max(0, hp-dmg)
		mess_log.append_bbcode("\n You hit [color=#ffffb4]Knight[/color] for [color=#00ff00]" + str(dmg) + "[/color] damage")
		
		if hp == 0:
			mess_log.append_bbcode("\n [color=#ffffb4]Knight[/color] died")
		if hp == 0:
			dead = true#
	else:
		mess_log.append_bbcode("\n You missed the [color=#ffffb4]Knight[/color]")
