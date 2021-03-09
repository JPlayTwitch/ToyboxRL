extends Sprite

var max_hp = 1000
var strength = 2
var hp = max_hp

signal turn_advance

func _input(event):
	if !event.is_pressed():
		return
	
	if event.is_action("Left"):
		try_move(-1,0)
	elif event.is_action("UpLeft"):
		try_move(-1,-1)
	elif event.is_action("Up"):
		try_move(0,-1)
	elif event.is_action("UpRight"):
		try_move(1,-1)
	elif event.is_action("Right"):
		try_move(1,0)
	elif event.is_action("DownRight"):
		try_move(1,1)
	elif event.is_action("Down"):
		try_move(0,1)
	elif event.is_action("DownLeft"):
		try_move(-1,1)
	elif event.is_action("Wait"):
		emit_signal("turn_advance")

func try_move(dx,dy):
	
	var game = get_parent()
	
	
	# Square we want to move to
	var x = game.player_tile.x + dx
	var y = game.player_tile.y + dy
	
	# If outside map, treat as stone
	var tile_type = game.tile_stone
	
	if x > 0 && x < game.level_size.x && y > 0 && y < game.level_size.y:
		tile_type = game.map[x][y]
	
	match tile_type:
		game.tile_floor:
			var blocked = false
			for enemy in game.enemies:
				if enemy.tile.x == x && enemy.tile.y == y:
					var dmg = max(1,strength + randi() % 4 + 1)
					enemy.sprite_node.take_damage(game,dmg)
					if enemy.sprite_node.dead:
						enemy.remove()
						game.enemies.erase(enemy)
					blocked = true
					break
			if !blocked:
				game.player_tile = Vector2(x,y)
			emit_signal("turn_advance")
		game.tile_ladder:
			game.level_num += 1
			game.build_level()
		game.tile_amulet:
			$HUD/EndScreen/Label.text = "You Win"
			$HUD/EndScreen.visible = true
	
	game.update_visuals()
