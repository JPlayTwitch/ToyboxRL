extends Sprite

#export onready var stats = $Stats

export(int) var max_hp = 20
onready var hp = max_hp
export(int) var dmg = 3
export(int) var weighting = 2
export(int) var vision = 10
export(int) var evasion = 5


func act(game,me):
	if self.visible:
		var self_point = game.enemy_pathfinding.get_closest_point(Vector3(me.tile.x,me.tile.y,0))
		var player_point = game.enemy_pathfinding.get_closest_point(Vector3(game.player_tile.x, game.player_tile.y, 0))
		var path = game.enemy_pathfinding.get_point_path(self_point, player_point)
		if path:
			assert(path.size() > 1)
			var move_tile = Vector2(path[1].x, path[1].y)
			if move_tile == game.player_tile:
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
