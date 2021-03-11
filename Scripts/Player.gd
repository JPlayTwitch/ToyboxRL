extends Sprite

onready var mess_log = get_node("/root/Game/MessageLog/MLogText")
onready var InvUI = get_node("/root/Game/Inventory/Inventory")

signal turn_advance

func _input(event):
	if !event.is_pressed():
		return
	
	# paralysed mode
	if PlayerStats.paralysed:
		if event.is_action("ui_accept"):
			pass_turns(20)
			PlayerStats.paralysed = false
	
	# non-inventory
	if !InvUI.visible:
		#confused motion
		if PlayerStats.confused > 0:
			if event.is_action("Left") || event.is_action("Right") || event.is_action("Up") || event.is_action("Down") \
				|| event.is_action("UpLeft") || event.is_action("DownLeft") || event.is_action("UpRight") \
				|| event.is_action("DownRight") || event.is_action("Wait"):
				try_move(randi() % 3 - 1, randi() % 3 - 1)
				mess_log.append_bbcode("\n You are confused and wandering aimlessly")
				PlayerStats.confused -= 1
		#standard motion
		else:
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
		if event.is_action("Inventory"):
			InvUI.visible = true
	#inventory
	else:
		if event.is_action("ui_cancel"):
			InvUI.visible = false
		if event.is_action("InvSlot0"):
			if InvDict.inventory.size()>0:
				BeanCatalogue.use_bean(InvDict.inventory.keys()[0])
		if event.is_action("InvSlot1"):
			if InvDict.inventory.size()>1:
				BeanCatalogue.use_bean(InvDict.inventory.keys()[1])
		if event.is_action("InvSlot2"):
			if InvDict.inventory.size()>2:
				BeanCatalogue.use_bean(InvDict.inventory.keys()[2])
		if event.is_action("InvSlot3"):
			if InvDict.inventory.size()>3:
				BeanCatalogue.use_bean(InvDict.inventory.keys()[3])
		if event.is_action("InvSlot4"):
			if InvDict.inventory.size()>4:
				BeanCatalogue.use_bean(InvDict.inventory.keys()[4])
		if event.is_action("InvSlot5"):
			if InvDict.inventory.size()>5:
				BeanCatalogue.use_bean(InvDict.inventory.keys()[5])
		if event.is_action("InvSlot6"):
			if InvDict.inventory.size()>6:
				BeanCatalogue.use_bean(InvDict.inventory.keys()[6])
		if event.is_action("InvSlot7"):
			if InvDict.inventory.size()>7:
				BeanCatalogue.use_bean(InvDict.inventory.keys()[7])
		if event.is_action("InvSlot8"):
			if InvDict.inventory.size()>8:
				BeanCatalogue.use_bean(InvDict.inventory.keys()[8])
		if event.is_action("InvSlot9"):
			if InvDict.inventory.size()>9:
				BeanCatalogue.use_bean(InvDict.inventory.keys()[9])

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
					var dmg = max(1,PlayerStats.strength + randi() % 4 + 1)
					enemy.sprite_node.take_damage(game,dmg)
					if enemy.sprite_node.dead:
						enemy.remove()
						game.enemies.erase(enemy)
					blocked = true
					break
			if !blocked:
				game.player_tile = Vector2(x,y)
				pickup_items()
			emit_signal("turn_advance")
		game.tile_ladder:
			game.level_num += 1
			game.build_level()
		game.tile_amulet:
			$HUD/EndScreen/Label.text = "You Win"
			$HUD/EndScreen.visible = true
	
	
	game.update_visuals()

func pickup_items():
	var game = get_node("/root/Game")
	var remove_queue = []
	for bean in game.beans:
		if bean.tile == game.player_tile:
			if BeanCatalogue.tasted[bean.effect]:
				mess_log.append_bbcode("\n Picked up "+BeanCatalogue.bean_name_tasted[bean.effect])
			else:
				mess_log.append_bbcode("\n Picked up "+BeanCatalogue.bean_name_untasted[bean.effect])
			remove_queue.append(bean)
			bean.remove()
			InvDict.additem(BeanCatalogue.effects_text[bean.effect])
			print(InvDict.inventory)
	
	for bean in remove_queue:
		game.beans.erase(bean)

func pass_turns(qty):
	for _i in range(qty):
		emit_signal("turn_advance")
