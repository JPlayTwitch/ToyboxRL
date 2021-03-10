extends Sprite

const BeanScene = preload("res://Items/Bean.tscn")
#const Catalogue = preload("res://Items/Bean_Catalogue.gd")
#onready var Catalogue = get_node("res://BeanCatalogue")
#onready var Catalogue = get_node("/root/BeanCatalogue")

#const bean_brawn_flavour = Catalogue.bean_brawn_flavour


class Bean extends Node:
	var tasted = false
	var name_untasted
	var name_tasted
	var flavour
	var tile
	var sprite_node
	
	func _init(game,x,y,type):
		tile = Vector2(x, y)
		sprite_node = BeanScene.instance()
		print(BeanCatalogue.bean_brawn_flavour)
		sprite_node.frame = BeanCatalogue.bean_brawn_flavour
		sprite_node.position = tile*game.TILE_SIZE
		game.add_child(sprite_node)
	
	func _remove():
		sprite_node.queue_free()
