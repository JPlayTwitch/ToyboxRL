extends Node

enum EnemyTypes {Teddy,Soldier}

const EnemyTeddy = preload("res://Enemies/Teddy.tscn")
const EnemySoldier = preload("res://Enemies/Soldier.tscn")

class Enemy extends Reference:
	var sprite_node
	var tile
	var max_hp
	var hp
	var dead = false
	
	func _init(game,enemy_type,x,y):
		match enemy_type:
			EnemyTypes.Teddy:
				sprite_node = EnemyTeddy.instance()
			EnemyTypes.Soldier:
				sprite_node = EnemySoldier.instance()
			_:
				sprite_node = EnemyTeddy.instance()
		max_hp = sprite_node.max_hp
		hp = max_hp
		tile = Vector2(x,y)
		sprite_node.position = tile * game.TILE_SIZE
		sprite_node.get_node("HPBar").rect_size.x = 0
		game.add_child(sprite_node)
	
	func remove():
		sprite_node.queue_free()
	
	func take_damage(game,dmg):
		if dead:
			return
		
		hp = max(0, hp-dmg)
		sprite_node.get_node("HPBar").rect_size.x = game.TILE_SIZE * hp / max_hp
		
		if hp == 0:
			dead = true
	
#	func act(game):
#		if sprite_node.visible:
#			var self_point = game.enemy_pathfinding.get_closest_point(Vector3(tile.x,tile.y,0))
#			var player_point = game.enemy_pathfinding.get_closest_point(Vector3(game.player_tile.x, game.player_tile.y, 0))
#			var path = game.enemy_pathfinding.get_point_path(self_point, player_point)
#			if path:
#				assert(path.size() > 1)
#				var move_tile = Vector2(path[1].x, path[1].y)
#
#				if move_tile == game.player_tile:
#					game.damage_player(1)
#				else:
#					var blocked = false
#					for enemy in game.enemies:
#						if enemy.tile == move_tile:
#							blocked = true
#							break
#
#					if !blocked:
#						tile = move_tile
