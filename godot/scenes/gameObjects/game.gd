extends Node2D

var tile_scene = preload("res://scenes/gameObjects/tuile_base.tscn")
var tiles = [preload("res://scenes/gameObjects/plaine.tscn"), preload("res://scenes/gameObjects/ville.tscn") ]
var modifiers = [preload("res://scenes/gameObjects/depoluplante.tscn"),preload("res://scenes/gameObjects/depoluplante.tscn")]
const board_size = 5

@onready var board = $board/TileMap
@onready var modmarkers = [$board/mod0, $board/mod1, $board/mod2]

func on_tile_pressed(coord):
	print(coord)

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	init_board()
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
		score += tile.pollution_modifier
	
	return score
	
func end_turn():
	pass
	#check board
	#hide remaining bonus?
	#then show score
	#wait for validation, if score > 0
	#animate board evolution
	#show bonus/malus
	#give hand

func get_tile_from_map_coord(coord: Vector2i):
	var tiles = board.get_children()
	for tile in tiles:
		if tile.tile_coord == coord:
			return tile

func _on_modfier_dropped(entity):
	var map_coord = board.local_to_map(entity.position)
	print(map_coord)
	if (map_coord.x < board_size and map_coord.y < board_size) and (map_coord.x > 0 and map_coord.y > 0):
		entity.visible = false
		var tile = get_tile_from_map_coord(map_coord)
		tile.add_modifier(entity.pollution_modifier)
		entity.queue_free()

	
