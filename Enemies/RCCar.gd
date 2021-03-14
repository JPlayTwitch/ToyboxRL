extends Sprite

#export onready var stats = $Stats

export(int) var max_hp = 40
onready var hp = max_hp
export(int) var attack_dice = 3
export(int) var strength = 3
export(int) var weighting = 6
export(int) var vision = 10
export(int) var evasion = 45
var dead = false
onready var mess_log = get_node("/root/Game/MessageLog/MLogText")
var has_target = false
var target_point
var type = "RCCar"


func act(game,me):
	if self.visible:
		# direct aim for this turn
		var player_point = game.enemy_pathfinding.get_closest_point(Vector3(game.player_tile.x, game.player_tile.y, 0))
		# set that point in case player leaves line of sight
		target_point = player_point
		has_target = true
		# move to/attack player
		var attacked = false
		for i in range(3):
			if !attacked:
				var self_point = game.enemy_pathfinding.get_closest_point(Vector3(me.tile.x,me.tile.y,0))
				var path = game.enemy_pathfinding.get_point_path(self_point, player_point)
				if path:
					assert(path.size() > 1)
					var move_tile = Vector2(path[1].x, path[1].y)
					if move_tile == game.player_tile:
						var dmg = randi() % attack_dice + strength
						var hit = randi() % 100 >= PlayerStats.evasion
						if hit:
							mess_log.append_bbcode("\n [color=#ff0000]RC Car[/color] bumped into your shins for [color=#ff0000]" + str(dmg) + "[/color] damage")
							game.damage_player(dmg)
						else:
							mess_log.append_bbcode("\n [color=#ff0000]RC Car[/color] revs its engine menacingly")
						attacked = true
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
	else:
		# where am I?
		var self_point = game.enemy_pathfinding.get_closest_point(Vector3(me.tile.x,me.tile.y,0))
		#If I don't have somewhere to drive, pick somewhere on the map at random
		if !has_target:
			var target_array = game.enemy_pathfinding.get_points()
			target_array.erase(self_point)
			target_point = target_array[randi() % target_array.size()]
		# drive
		var path = game.enemy_pathfinding.get_point_path(self_point, target_point)
		# only allow enemy to move if this is an unoccupied floor tile
		var blocked = false
		if path:
			assert(path.size() > 1)
			for i in range(min(path.size()-1,3)):
				var move_tile = Vector2(path[i].x, path[i].y)
				if move_tile == game.player_tile:
					blocked = true
				for enemy in game.enemies:
					if enemy.tile == move_tile:
						blocked = true
						break
				if !blocked:
					me.tile = move_tile

func take_damage(game,dmg):
	var hit = randi() % 100 >= evasion
	if hit:
		hp = max(0, hp-dmg)
		mess_log.append_bbcode("\n You hit [color=#ff0000]RC Car[/color] for [color=#00ff00]" + str(dmg) + "[/color] damage")
		
		if hp == 0:
			mess_log.append_bbcode("\n [color=#ff0000]RC Car[/color] died")
		if hp == 0:
			dead = true#
	else:
		mess_log.append_bbcode("\n You missed the [color=#ff0000]RC Car[/color]")
