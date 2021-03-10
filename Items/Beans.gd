extends Sprite

const BeanScene = preload("res://Items/Bean.tscn")
#const Catalogue = preload("res://Items/Bean_Catalogue.gd")
#onready var Catalogue = get_node("res://BeanCatalogue")
#onready var Catalogue = get_node("/root/BeanCatalogue")

#const bean_brawn_flavour = Catalogue.bean_brawn_flavour


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
