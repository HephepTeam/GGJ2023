extends Node2D

signal board_ready

var tile_scene = preload("res://scenes/gameObjects/tuile_base.tscn")
var tiles = [preload("res://scenes/gameObjects/plaine.tscn"), preload("res://scenes/gameObjects/ville.tscn"),preload("res://scenes/gameObjects/foret.tscn") ]
var modifiers = [preload("res://scenes/gameObjects/depoluplante.tscn"),preload("res://scenes/gameObjects/depoluplante.tscn")]
const board_size = 5

enum gameStates {PLAYING, WAITING_FOR_INPUT}
var gameState = gameStates.PLAYING
var turn_left = 3

@onready var board = $board/TileMap
@onready var modmarkers = [$board/mod0, $board/mod1, $board/mod2]

func on_tile_pressed(coord):
	print(coord)

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	init_board()
	await board_ready
	apply_side_effect()
	pick_modifiers()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func init_board():
	for i in range(0,board_size):
		for j in range(0,board_size):
			var tile = tiles[randi_range(0,tiles.size()-1)].instantiate()
			tile.set_tile_coord(Vector2i(i,j))
			tile.position = board.map_to_local(Vector2i(i,j))
			tile.connect("tile_pressed", on_tile_pressed)
			board.add_child(tile)
			tile.drop_animation()
			await get_tree().create_timer(0.2).timeout
	await get_tree().create_timer(0.1).timeout
	emit_signal("board_ready")
			

func apply_side_effect():
	var tiles_list = []
	#parcourir les tuiles (children)
	for tile in board.get_children():
		if tile.modifiers.side_effect_modifier !=0:
			tiles_list = [tile.tile_coord+Vector2i(-1,0),tile.tile_coord+Vector2i(1,0),tile.tile_coord+Vector2i(0,-1),tile.tile_coord+Vector2i(0,+1)]
			for subtile in board.get_children():
				if subtile.tile_coord in tiles_list:
					tiles_list.erase(subtile.tile_coord)
					subtile.add_modifier(tile.modifiers.side_effect_modifier, null)
		await get_tree().create_timer(0.1).timeout
	
			
			
func pick_modifiers():
	for i in range(3):
		var mod = modifiers[randi_range(0,modifiers.size()-1)].instantiate()
		mod.position = modmarkers[i].position
		mod.connect("dropped", _on_modfier_dropped)
		$board.add_child(mod)

func check_board():
	var score = 0
	var tiles = board.get_children()
	for tile in tiles:
		score += tile.modifiers.pollution_modifier
	
	return score
	
func end_turn():
	pass
	#check board
	var result = check_board()
	for tile in board.get_children():
		tile.make_highlight()
		await get_tree().create_timer(0.1).timeout
		
	$CanvasLayer/Score.text = str(result) + " pts"
	$CanvasLayer/Score.visible = true
	
	#then show score
	if result < 0:
		$CanvasLayer/Score.modulate = Color.BROWN
	else:
		$CanvasLayer/Score.modulate = Color.CHARTREUSE
	
	gameState = gameStates.WAITING_FOR_INPUT
	#wait for validation, if score > 0
	#animate board evolution
	#show bonus/malus
	#give hand
	
func process_board_evolution():
	pass

func get_tile_from_map_coord(coord: Vector2i):
	var tiles = board.get_children()
	for tile in tiles:
		if tile.tile_coord == coord:
			return tile

func _on_modfier_dropped(entity):
	var map_coord = board.local_to_map(entity.position)
	print(map_coord)
	if (map_coord.x < board_size and map_coord.y < board_size) and (map_coord.x >= 0 and map_coord.y >= 0):
		var tile = get_tile_from_map_coord(map_coord)
		print(tile.name)
		if tile.name.contains(entity.modifiers.apply_on):
			entity.visible = false
			tile.add_modifier(entity.modifiers.pollution_modifier, entity.get_texture())
			entity.queue_free()
		
func _input(event):
	if gameState == gameStates.WAITING_FOR_INPUT:
		if turn_left > 0:
			turn_left-=1
			#reset_board()
		else:
			print("game win")

	
func _on_sprite_button_pressed():
	print("end turn")
	end_turn()
	
