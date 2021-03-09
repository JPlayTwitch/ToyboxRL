extends Sprite

#export onready var stats = $Stats

export(int) var max_hp = 20
onready var hp = max_hp
export(int) var attack_dice = 3
export(int) var strength = 2
export(int) var weighting = 2
export(int) var vision = 10
export(int) var evasion = 5
var dead = false
onready var mess_log = get_node("/root/Game/MessageLog/MLogText")


func act(game,me):
	if self.visible:
		var self_point = game.enemy_pathfinding.get_closest_point(Vector3(me.tile.x,me.tile.y,0))
		var player_point = game.enemy_pathfinding.get_closest_point(Vector3(game.player_tile.x, game.player_tile.y, 0))
		var path = game.enemy_pathfinding.get_point_path(self_point, player_point)
		if path:
			assert(path.size() > 1)
			var move_tile = Vector2(path[1].x, path[1].y)
			if move_tile == game.player_tile:
				var dmg = randi() % attack_dice + strength
				mess_log.append_bbcode("\n [color=#bd9521]Teddy Bear[/color] clawed at you for [color=#ff0000]" + str(dmg) + "[/color] damage")
				game.damage_player(dmg)
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
				var blocked = false
				for enemy in game.enemies:
					if enemy.tile == move_tile:
						blocked = true
						break
				if !blocked:
					me.tile = move_tile

func take_damage(game,dmg):
	
	hp = max(0, hp-dmg)
	mess_log.append_bbcode("\n You hit [color=#bd9521]Teddy Bear[/color] for [color=#00ff00]" + str(dmg) + "[/color] damage")
	
	if hp == 0:
		mess_log.append_bbcode("\n [color=#bd9521]Teddy Bear[/color] died")
	if hp == 0:
		dead = true
