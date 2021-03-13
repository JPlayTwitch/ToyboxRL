extends Node

enum EnemyTypes {Teddy,Soldier,Nutcracker,RCCar,Knight,DrinkingBird}

const EnemyTeddy = preload("res://Enemies/Teddy.tscn")
const EnemySoldier = preload("res://Enemies/Soldier.tscn")
const EnemyNutcracker = preload("res://Enemies/Nutcracker.tscn")
const EnemyRCCar = preload("res://Enemies/RCCar.tscn")
const EnemyKnight = preload("res://Enemies/Knight.tscn")
const DrinkingBird = preload("res://Enemies/DrinkingBird.tscn")

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
			EnemyTypes.Nutcracker:
				sprite_node = EnemyNutcracker.instance()
			EnemyTypes.RCCar:
				sprite_node = EnemyRCCar.instance()
			EnemyTypes.Knight:
				sprite_node = EnemyKnight.instance()
			EnemyTypes.DrinkingBird:
				sprite_node = DrinkingBird.instance()
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
