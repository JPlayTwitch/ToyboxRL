extends Sprite

const BeanScene = preload("res://Items/Bean.tscn")


class Bean extends Node:
	var flavour
	var tile
	var sprite_node
	var effect
	
	func _init(game,x,y,type):
		tile = Vector2(x, y)
		sprite_node = BeanScene.instance()
		sprite_node.frame = BeanCatalogue.bean_flavour[type]
		sprite_node.position = tile*game.TILE_SIZE
		effect = type
		game.add_child(sprite_node)
	
	func remove():
		sprite_node.queue_free()
