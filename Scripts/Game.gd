extends Node2D

#TESTING ONLY
var visibility_disabled = false

# Display
const WINDOW_WIDTH = 1280
const WINDOW_HEIGHT = 740

# Levels
const TILE_SIZE = 32
const LEVEL_SIZES = [
	Vector2(40,40),
	Vector2(45,45),
	Vector2(50,50),
	Vector2(55,55),
	Vector2(60,60)
]
const LEVEL_ROOM_COUNTS = [5,7,9,12,15]
const MIN_ROOM_DIMENSION = 6
const MAX_ROOM_DIMENSION = 12

# Player Attributes
const PlayerScn = preload("res://Player.tscn")
var Player = PlayerScn.instance()





# Enemies
var Enemies = preload("res://Scripts/Enemies.gd")
const LEVEL_ENEMY_PTS = [19,45,81,97,130]



# Beans
const BEAN_GEN = [5,9,13,20,25]
var Beans = preload("res://Items/Beans.gd")



# Tileset
enum Tile {Wall,Floor1,Floor2,Ladder,Stone,Amulet}
enum Visibility {Undiscovered,Fog,Visible}
enum FloorType{Std,Chess}

# Current Level
var level_num = 0
var map = []
var floor_type = []
var rooms = []
var rooms_type = []
var level_size
var enemies = []
var beans = []

# Node Refs
onready var tile_map = $TileMap
onready var player = $Player
onready var visibility_map = $VisibilityMap

onready var tile_floor = tile_map.tile_set.find_tile_by_name("Floor")
onready var tile_wall = tile_map.tile_set.find_tile_by_name("Wall")
onready var tile_ladder = tile_map.tile_set.find_tile_by_name("Ladder")
onready var tile_stone = tile_map.tile_set.find_tile_by_name("Stone")
onready var tile_amulet = tile_map.tile_set.find_tile_by_name("Amulet")
onready var tile_wall_ul = tile_map.tile_set.find_tile_by_name("WallCornerUL")
onready var tile_wall_ur = tile_map.tile_set.find_tile_by_name("WallCornerUR")
onready var tile_wall_dl = tile_map.tile_set.find_tile_by_name("WallCornerDL")
onready var tile_wall_dr = tile_map.tile_set.find_tile_by_name("WallCornerDR")
onready var tile_chess = tile_map.tile_set.find_tile_by_name("Chessboard")


# Game State
var player_tile
var enemy_pathfinding


# Called when the node enters the scene tree for the first time.
func _ready():
	OS.set_window_size(Vector2(WINDOW_WIDTH,WINDOW_HEIGHT))
	randomize()
	BeanCatalogue.assign_beans()
	build_level()











func damage_player(dmg):
	PlayerStats.hp = max(0, PlayerStats.hp - dmg)
	if PlayerStats.hp == 0:
		$HUD/EndScreen/Label.text = "You Lose"
		$HUD/EndScreen.visible = true

func build_level():
	# start with a blank map
	rooms.clear()
	map.clear()
	tile_map.clear()
	visibility_map.clear()
	floor_type.clear()
	rooms_type.clear()
	
	for enemy in enemies:
		enemy.remove()
	enemies.clear()
	for bean in beans:
		bean.remove()
	beans.clear()
	
	enemy_pathfinding = AStar.new()
	
	
	# Make the overall size and set bg to stone
	level_size = LEVEL_SIZES[level_num]
	for x in range(level_size.x):
		map.append([])
		floor_type.append([])
		for y in range(level_size.y):
			map[x].append(tile_stone)
			tile_map.set_cell(x,y,tile_stone)
			visibility_map.set_cell(x,y,Visibility.Undiscovered)
			floor_type[x].append(FloorType.Std)
	
	# Make Rooms
	var free_regions = [Rect2(Vector2(2,2), level_size - Vector2(4,4))]
	var num_rooms = LEVEL_ROOM_COUNTS[level_num]
	for _i in range(num_rooms):
		add_room(free_regions)
		if free_regions.empty():
			break
	
	# Make Corridors
	connect_rooms()
	
	# Make Diagonals
#	make_diagonals()
	
	# Place Player
	var selected_room = null
	while selected_room == null:
		selected_room = randi() % rooms.size()
		if rooms_type[selected_room] != FloorType.Std:
			selected_room = null
		
	var start_room = rooms[selected_room]
	var player_x = start_room.position.x + 1 + (randi() % int(start_room.size.x - 2))
	var player_y = start_room.position.y + 1 + (randi() % int(start_room.size.y - 2))
	player_tile = Vector2(player_x,player_y)
	call_deferred("update_visuals")
	
	# Place ladder/Amulet
	selected_room = null
	while selected_room == null:
		selected_room = randi() % rooms.size()
		if rooms[selected_room] == start_room:
			selected_room = null
		elif rooms_type[selected_room] != FloorType.Std:
			selected_room = null
	var end_room = rooms[selected_room]
	var ladder_x = end_room.position.x + 1 + (randi() % int(end_room.size.x - 2))
	var ladder_y = end_room.position.y + 1 + (randi() % int(end_room.size.y - 2))
	if level_num + 1 < LEVEL_ROOM_COUNTS.size():
		set_tile(ladder_x,ladder_y,tile_ladder,FloorType.Std)
	else:
		set_tile(ladder_x,ladder_y,tile_amulet,FloorType.Std)
	
	var bean_counter = BEAN_GEN[level_num]
	while bean_counter > 0:
		var room = rooms[randi() % (rooms.size())]
		var x = room.position.x + 1 + randi() % int(room.size.x-2)
		var y = room.position.y + 1 + randi() % int(room.size.y-2)
		if map[x][y] == tile_floor:
			if x == player_tile.x && y == player_tile.y:
				pass
			else:
				beans.append(Beans.Bean.new(self,x,y,randi() % BeanCatalogue.Effects.size()))
				bean_counter -= 1
		
	
	# Place Enemies
	var num_enemies = LEVEL_ENEMY_PTS[level_num]
	var enemy_l0 = [Enemies.EnemyTypes.Teddy,Enemies.EnemyTypes.Teddy,Enemies.EnemyTypes.Teddy,Enemies.EnemyTypes.Soldier,Enemies.EnemyTypes.Soldier]
	var enemy_l1 = [Enemies.EnemyTypes.Teddy,Enemies.EnemyTypes.Teddy,Enemies.EnemyTypes.Soldier,Enemies.EnemyTypes.Soldier,Enemies.EnemyTypes.RCCar]
	var enemy_l2 = [Enemies.EnemyTypes.Teddy,Enemies.EnemyTypes.Soldier,Enemies.EnemyTypes.Nutcracker,Enemies.EnemyTypes.RCCar]
	var enemy_l3 = [Enemies.EnemyTypes.Teddy,Enemies.EnemyTypes.Soldier,Enemies.EnemyTypes.Nutcracker,Enemies.EnemyTypes.RCCar]
	var enemy_l4 = [Enemies.EnemyTypes.Teddy,Enemies.EnemyTypes.Soldier,Enemies.EnemyTypes.Nutcracker,Enemies.EnemyTypes.Nutcracker,Enemies.EnemyTypes.RCCar]
	while num_enemies > 0:
		var usable_room = false
		var room_num
		while usable_room == false:
			room_num = randi() % (rooms.size())
			if rooms_type[room_num] == FloorType.Std && rooms[room_num] != start_room:
				usable_room = true
		var room = rooms[room_num]
		
		var x = room.position.x + 1 + randi() % int(room.size.x - 2)
		var y = room.position.y + 1 + randi() % int(room.size.y - 2)
		
		var blocked = false
		if map[x][y] != tile_floor:
			blocked = true
		else:
			for enemy in enemies:
				if enemy.tile.x == x && enemy.tile.y == y:
					blocked = true
					break
		
		var enemy_type = 0
		
		if !blocked:
			match level_num:
				0:
					enemy_type = enemy_l0[randi() % enemy_l0.size()]
				1:
					enemy_type = enemy_l1[randi() % enemy_l1.size()]
				2:
					enemy_type = enemy_l2[randi() % enemy_l2.size()]
				3:
					enemy_type = enemy_l3[randi() % enemy_l3.size()]
				4:
					enemy_type = enemy_l4[randi() % enemy_l4.size()]
			var enemy = Enemies.Enemy.new(self,enemy_type,x,y)
			num_enemies -= enemy.sprite_node.weighting
			enemies.append(enemy)
	
	$HUD/Level.text = "Level: " + str(level_num+1)

func clear_path(tile):
	var new_point = enemy_pathfinding.get_available_point_id()
	enemy_pathfinding.add_point(new_point,Vector3(tile.x,tile.y,0))
	var points_to_connect = []
	
	if tile.x > 0:
		match map[tile.x-1][tile.y]:
			tile_floor:
				points_to_connect.append(enemy_pathfinding.get_closest_point(Vector3(tile.x-1,tile.y,0)))
	if tile.x > 0 && tile.y > 0:
		match map[tile.x-1][tile.y-1]:
			tile_floor:
				points_to_connect.append(enemy_pathfinding.get_closest_point(Vector3(tile.x-1,tile.y-1,0)))
	if tile.y > 0:
		match map[tile.x][tile.y-1]:
			tile_floor:
				points_to_connect.append(enemy_pathfinding.get_closest_point(Vector3(tile.x,tile.y-1,0)))
	if tile.x < level_size.x - 1 && tile.y > 0:
		match map[tile.x+1][tile.y-1]:
			tile_floor:
				points_to_connect.append(enemy_pathfinding.get_closest_point(Vector3(tile.x+1,tile.y-1,0)))
	if tile.x < level_size.x - 1:
		match map[tile.x+1][tile.y]:
			tile_floor:
				points_to_connect.append(enemy_pathfinding.get_closest_point(Vector3(tile.x+1,tile.y,0)))
	if tile.x < level_size.x - 1 && tile.y < level_size.y-1:
		match map[tile.x+1][tile.y+1]:
			tile_floor:
				points_to_connect.append(enemy_pathfinding.get_closest_point(Vector3(tile.x+1,tile.y+1,0)))
	if tile.y < level_size.y - 1:
		match map[tile.x][tile.y+1]:
			tile_floor:
				points_to_connect.append(enemy_pathfinding.get_closest_point(Vector3(tile.x,tile.y+1,0)))
	if tile.x > 0 && tile.y < level_size.y-1:
		match map[tile.x-1][tile.y+1]:
			tile_floor:
				points_to_connect.append(enemy_pathfinding.get_closest_point(Vector3(tile.x-1,tile.y+1,0)))
	
	for point in points_to_connect:
		enemy_pathfinding.connect_points(new_point, point)
		

func update_visuals():
	yield(get_tree(),"idle_frame")
	# Position Player
	player.position = player_tile * TILE_SIZE
	var player_center = tile_to_pixel_center(player_tile.x,player_tile.y)
	var space_state = get_world_2d().direct_space_state
	var x_dir
	var y_dir
	var test_point
	
	for x in range(level_size.x):
		for y in range(level_size.y):
			if !visibility_disabled:
				x_dir = 1 if x < player_tile.x else -1
				y_dir = 1 if y < player_tile.y else -1
				test_point = tile_to_pixel_center(x, y) + Vector2(x_dir, y_dir) * TILE_SIZE / 2
				
				var occlusion = space_state.intersect_ray(player_center, test_point, [self], 0b1)
				
				if !occlusion || (occlusion.position - test_point).length() < 0.1:
					visibility_map.set_cell(x, y, Visibility.Visible)
				elif visibility_map.get_cell(x,y) == Visibility.Visible:
					visibility_map.set_cell(x,y,Visibility.Fog)
			else:
				visibility_map.set_cell(x,y,Visibility.Visible)
	
	yield(get_tree(),"idle_frame")
	
	for enemy in enemies:
		enemy.sprite_node.position = enemy.tile * TILE_SIZE
		if visibility_map.get_cell(enemy.tile.x,enemy.tile.y) == Visibility.Visible:
			enemy.sprite_node.visible = true
		else:
			enemy.sprite_node.visible = false
	
	for bean in beans:
		if !bean.sprite_node.visible:
			if visibility_map.get_cell(bean.tile.x,bean.tile.y) == Visibility.Visible:
				bean.sprite_node.visible = true
	
	
	$HUD/HP.text = "HP: " + str(PlayerStats.hp) + "/" + str(PlayerStats.max_hp)
	$HUD/Strength.text = "STR: " + str(PlayerStats.strength)
	$HUD/Evasion.text = "Evasion: " + str(PlayerStats.evasion) + "%"

func tile_to_pixel_center(x,y):
	return Vector2((x + 0.5) * TILE_SIZE, (y + 0.5) * TILE_SIZE)

func connect_rooms():
	# Build an AStar Graph of the area where we can add corridors
	var stone_graph = AStar.new()
	var point_id = 0
	for x in range(level_size.x):
		for y in range(level_size.y):
			if map[x][y] == tile_stone:
				stone_graph.add_point(point_id,Vector3(x,y,0))
				
				# Connect to left if also stone
				if x>0 && map[x-1][y] == tile_stone:
					var left_point = stone_graph.get_closest_point(Vector3(x-1,y,0))
					stone_graph.connect_points(point_id,left_point)
				
				# Connect to above if also stone
				if y>0 && map[x][y-1] == tile_stone:
					var up_point = stone_graph.get_closest_point(Vector3(x,y-1,0))
					stone_graph.connect_points(point_id,up_point)
				
				point_id += 1
	
	# Build an AStar Graph of room connections
	var room_graph = AStar.new()
	point_id = 0
	
	for room in rooms:
		var room_centre = room.position + room.size/2
		room_graph.add_point(point_id,Vector3(room_centre.x, room_centre.y, 0))
		point_id += 1
	
	# Add random connections until everything is connected
	while !is_everything_connected(room_graph):
		add_random_connection(stone_graph, room_graph)
	

func is_everything_connected(graph):
	var points = graph.get_points()
	var start = points.pop_back()
	for point in points:
		var path = graph.get_point_path(start,point)
		if !path:
			return false
	return true

func add_random_connection(stone_graph,room_graph):
	# Pick rooms to connect
	var start_room_id = get_least_connected_point(room_graph)
	var end_room_id = get_nearest_unconnected_point(room_graph,start_room_id)
	
	var start_position = pick_random_door_location(rooms[start_room_id])
	var end_position = pick_random_door_location(rooms[end_room_id])
	
	var closest_start_point = stone_graph.get_closest_point(start_position)
	var closest_end_point = stone_graph.get_closest_point(end_position)
	
	var path = stone_graph.get_point_path(closest_start_point,closest_end_point)
	assert(path)
	
	path.append(start_position)
	path.append(end_position)
	for position in path:
		set_tile(position.x,position.y,tile_floor,FloorType.Std)
	
	room_graph.connect_points(start_room_id,end_room_id)

func get_least_connected_point(graph):
	var point_ids = graph.get_points()
	var least
	var tied_for_least = []
	
	for point in point_ids:
		var count = graph.get_point_connections(point).size()
		if !least || count < least:
			least = count
			tied_for_least = [point]
		elif count == least:
			tied_for_least.append(point)
	
	return tied_for_least[randi() % tied_for_least.size()]

func get_nearest_unconnected_point(graph,target_point):
	var target_position = graph.get_point_position(target_point)
	var point_ids = graph.get_points()
	var nearest
	var tied_for_nearest = []
	
	for point in point_ids:
		# If "point" is the point we are routing to, skip it
		if point == target_point:
			continue
		
		# If "point" is already connected, skip it
		var path = graph.get_point_path(point,target_point)
		if path:
			continue
		
		var dist = (graph.get_point_position(point) - target_position).length()
		
		if !nearest || dist < nearest:
			nearest = dist
			tied_for_nearest = [point]
#		elif dist == nearest:
#			tied_for_nearest.append[point]
	
	return tied_for_nearest[randi() % tied_for_nearest.size()]

func pick_random_door_location(room):
	var options = []
	for x in range(room.position.x + 1, room.end.x - 2):
		options.append(Vector3(x,room.position.y,0))
		options.append(Vector3(x,room.end.y-1,0))
	for y in range(room.position.y + 1, room.end.y - 2):
		options.append(Vector3(room.position.x,y,0))
		options.append(Vector3(room.end.x-1,y,0))
	return options[randi() % options.size()]

func add_room(free_regions):
	var region = free_regions[randi() % free_regions.size()]
	
	# Set Room Size
	var size_x = MIN_ROOM_DIMENSION
	if region.size.x > MIN_ROOM_DIMENSION:
		size_x += randi() % int(region.size.x - MIN_ROOM_DIMENSION)
	size_x = min(size_x, MAX_ROOM_DIMENSION)
	
	var size_y = MIN_ROOM_DIMENSION
	if region.size.y > MIN_ROOM_DIMENSION:
		size_y += randi() % int(region.size.y - MIN_ROOM_DIMENSION)
	size_y = min(size_y,MAX_ROOM_DIMENSION)
	
	# Set Room Start Position
	var start_x = region.position.x
	if region.size.x > size_x:
		start_x += randi() % int(region.size.x - size_x)
	
	var start_y = region.position.y
	if region.size.y > size_y:
		start_y += randi() % int(region.size.y - size_y)
	
	var force_square = randi() % 20
	if force_square <6:
		if size_x > 10 && size_y > 10:
			size_x = 10
			size_y = 10
#		size_x = min(size_x, 10)
#		size_y = min(10, size_y)
	
	# Add Room to List
	var room = Rect2(start_x,start_y,size_x,size_y)
	rooms.append(room)
	var room_type
	# Chess room
	if size_x == 10 && size_y == 10:
		room_type = FloorType.Chess
		var enemy = Enemies.Enemy.new(self,Enemies.EnemyTypes.Knight,start_x+2,start_y+2)
		enemies.append(enemy)
		enemy = Enemies.Enemy.new(self,Enemies.EnemyTypes.Knight,start_x+2,start_y+7)
		enemies.append(enemy)
		enemy = Enemies.Enemy.new(self,Enemies.EnemyTypes.Knight,start_x+7,start_y+2)
		enemies.append(enemy)
		enemy = Enemies.Enemy.new(self,Enemies.EnemyTypes.Knight,start_x+7,start_y+7)
		enemies.append(enemy)
		beans.append(Beans.Bean.new(self,start_x+4,start_y+4,randi() % BeanCatalogue.Effects.size()))
		beans.append(Beans.Bean.new(self,start_x+4,start_y+5,randi() % BeanCatalogue.Effects.size()))
		beans.append(Beans.Bean.new(self,start_x+5,start_y+4,randi() % BeanCatalogue.Effects.size()))
		beans.append(Beans.Bean.new(self,start_x+5,start_y+5,randi() % BeanCatalogue.Effects.size()))
	else:
		room_type = FloorType.Std
	
	rooms_type.append(room_type)
	
	# Set Room Tiles
	for x in range(start_x,start_x + size_x):
		set_tile(x,start_y, tile_wall,FloorType.Std)
		set_tile(x,start_y + size_y - 1, tile_wall,FloorType.Std)
	
	for y in range(start_y+1, start_y + size_y - 1):
		set_tile(start_x, y, tile_wall,FloorType.Std)
		set_tile(start_x + size_x - 1, y, tile_wall,FloorType.Std)
		
		for x in range(start_x + 1, start_x + size_x - 1):
			set_tile(x,y,tile_floor,room_type)
			if room_type == FloorType.Chess:
				floor_type[x][y] = FloorType.Chess
	
	# Remove the room from the region
	cut_regions(free_regions,room)

func cut_regions(free_regions,region_to_remove):
	var removal_queue = []
	var addition_queue = []
	
	# Evaluate free_regions to mark for editing
	for region in free_regions:
		if region.intersects(region_to_remove):
			removal_queue.append(region)
			
			# leftovers
			var leftover_left = region_to_remove.position.x - region.position.x -1
			var leftover_right = region.end.x - region_to_remove.end.x - 1
			var leftover_above = region_to_remove.position.y - region.position.y - 1
			var leftover_below = region.end.y - region_to_remove.end.y - 1
			
			# If space in leftovers add room
			if leftover_left >= MIN_ROOM_DIMENSION:
				addition_queue.append(Rect2(region.position, Vector2(leftover_left,region.size.y)))
			if leftover_right >= MIN_ROOM_DIMENSION:
				addition_queue.append(Rect2(Vector2(region_to_remove.end.x +1, region.position.y), Vector2(leftover_right,region.size.y)))
			if leftover_above >= MIN_ROOM_DIMENSION:
				addition_queue.append(Rect2(region.position, Vector2(region.size.x,leftover_above)))
			if leftover_below >= MIN_ROOM_DIMENSION:
				addition_queue.append(Rect2(Vector2(region.position.x, region_to_remove.end.y +1), Vector2(region.size.x,leftover_below)))
	
	# Actually edit free-regions
	for region in removal_queue:
		free_regions.erase(region)
	
	for region in addition_queue:
		free_regions.append(region)

func set_tile(x, y, type,floor_sprite):
	map[x][y] = type
	if type == tile_floor:
		if floor_sprite == FloorType.Chess:
			if int(x + y) % 2 == 1:
				tile_map.set_cell(x,y,tile_chess,false,false,false,Vector2(1,0))
			else:
				tile_map.set_cell(x,y,tile_chess,false,false,false,Vector2(0,0))
		else:
			if int(x + y) % 2 == 1:
				tile_map.set_cell(x,y,type,false,false,false,Vector2(1,0))
			else:
				tile_map.set_cell(x,y,type,false,false,false,Vector2(0,0))
	else:
		if int(x + y) % 2 == 1:
			tile_map.set_cell(x,y,type,false,false,false,Vector2(1,0))
		else:
			tile_map.set_cell(x,y,type,false,false,false,Vector2(0,0))
	
	match type:
		tile_floor:
			clear_path(Vector2(x,y))

func _on_Button_pressed():
	level_num = 0
	build_level()
	$HUD/EndScreen.visible = false
	PlayerStats.hp = PlayerStats.max_hp


func _on_Player_turn_advance():
	for enemy in enemies:
		enemy.sprite_node.act(self,enemy)
	update_visuals()
