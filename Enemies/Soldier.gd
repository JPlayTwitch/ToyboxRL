extends Sprite

#export onready var stats = $Stats

export(int) var max_hp = 13
onready var hp = max_hp
export(int) var strength = 1
export(int) var attack_dice = 4
export(int) var weighting = 3
export(int) var vision = 10
export(int) var evasion = 5
export(int) var attack_range = 5

func act(game,me):
	if self.visible:
		var self_point = game.enemy_pathfinding.get_closest_point(Vector3(me.tile.x,me.tile.y,0))
		var player_point = game.enemy_pathfinding.get_closest_point(Vector3(game.player_tile.x, game.player_tile.y, 0))
		var path = game.enemy_pathfinding.get_point_path(self_point, player_point)
		var attacking = false
		if path:
			assert(path.size() > 1)
			var move_tile = Vector2(path[1].x, path[1].y)
			# if they are out of range
			if path.size()>attack_range:
				var blocked = false
				for enemy in game.enemies:
					if enemy.tile == move_tile:
						blocked = true
						break
				if !blocked:
					me.tile = move_tile
			# if you are next to the player
			elif move_tile == game.player_tile:
				# find somewhere to run directly opposite the player
				var flee_tile = 2*Vector2(me.tile.x,me.tile.y)-Vector2(game.player_tile.x, game.player_tile.y)
				# only allow enemy to flee if this is an unoccupied floor tile
				var blocked = false
				if game.map[flee_tile.x][flee_tile.y] == game.tile_floor:
					for enemy in game.enemies:
						if enemy.tile == flee_tile:
							blocked = true
							break
				else:
					blocked = true
				if !blocked:
					me.tile = flee_tile
				if blocked:
					attacking = true
			else:
				attacking = true
		
		if attacking:
			
			# check if there is anything in the way
			var space_state = get_world_2d().direct_space_state
			var player_center = game.tile_to_pixel_center(game.player_tile.x, game.player_tile.y)
			var x_dir = 1 if game.player_tile.x < me.tile.x else -1
			var y_dir = 1 if game.player_tile.y < me.tile.y else -1
			var test_point = game.tile_to_pixel_center(me.tile.x,me.tile.y) + Vector2(x_dir, y_dir) * game.TILE_SIZE / 2
#			var test_point = game.tile_to_pixel_center(game.player.tile.x,game.player.tile.y)
			var occlusion = space_state.intersect_ray(player_center, test_point, [self], 0b1)
			
			if !occlusion || (occlusion.position - test_point).length() < 0.1:
				var dmg = randi() % attack_dice + strength
				var mess_log = get_node("/root/Game/MessageLog/MLogText")
				mess_log.append_bbcode("\n [color=#05431a]Green Army Man[/color] shot you for [color=#ff0000]" + str(dmg) + "[/color] damage")
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
