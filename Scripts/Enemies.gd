extends Node

enum EnemyTypes {Teddy,Soldier}

const EnemyTeddy = preload("res://Enemies/Teddy.tscn")
const EnemySoldier = preload("res://Enemies/Soldier.tscn")

class Enemy extends Node:
	var sprite_node
	var tile
	var max_hp
	var hp
	var dead = false
	var type
	
	func _init(game,enemy_type,x,y):
		type = enemy_type
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
