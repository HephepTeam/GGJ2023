extends Node2D

signal board_ready
signal restart_game

const description = "Pollution : [color=%s]%s[/color]\nBonus sur les tuiles adjacentes: [color=%s]%s[/color]\nEffet: %s "

var tile_scene = preload("res://scenes/gameObjects/tuile_base.tscn")
var plaine_tile = preload("res://scenes/gameObjects/plaine.tscn")
var foret_tile = preload("res://scenes/gameObjects/foret.tscn")
var ville_tile = preload("res://scenes/gameObjects/ville.tscn")
var usine_tile = preload("res://scenes/gameObjects/usine.tscn")
var tiles = [foret_tile, foret_tile, plaine_tile, foret_tile, usine_tile, usine_tile, usine_tile, \
	plaine_tile, ville_tile, ville_tile, ville_tile, usine_tile, plaine_tile, plaine_tile, ville_tile, \
	ville_tile, ville_tile, ville_tile, plaine_tile, plaine_tile, plaine_tile, ville_tile, plaine_tile, plaine_tile, plaine_tile]
var modifiers = [preload("res://scenes/gameObjects/depoluplante.tscn"),preload("res://scenes/gameObjects/vegetalisation.tscn"),preload("res://scenes/gameObjects/reforestation.tscn")]

const board_size = 5

enum gameStates {INIT, PLAYING, WAITING_FOR_INPUT}
var gameState = gameStates.INIT
var game_over = false
var turn_count = 0
var modifier_available = 3
var modifier_picked_twice = false



@onready var board = $board/TileMap
@onready var modmarkers = [$board/mod0, $board/mod1, $board/mod2]

func on_tile_pressed(coord):
	print(coord)
	
func on_tile_hovered(tile):
	if tile != null:
		var bonus = "+"+str(tile.pollution_modifier) if (+tile.pollution_modifier >=0) else str(tile.pollution_modifier)
		var side = "+"+str(tile.side_effect_modifier) if (tile.side_effect_modifier >=0) else str(tile.side_effect_modifier)
		var color =""
		if tile.pollution_modifier >= 0:
			color= "green"
		else:
			color = "red"

		var full_text = description % [color,bonus,color,side, tile.special_effect]
		show_tooltip(full_text)
	else:
		hide_tooltip()
	

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.game = self
	Globals.start_music()
	
	randomize()
	init_board()
	await board_ready
	apply_side_effect()
	pick_modifiers()
	gameState = gameStates.PLAYING

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func init_board():
	tiles.shuffle()
	for i in range(0,board_size):
		for j in range(0,board_size):
#			var tile = tiles[randi_range(0,tiles.size()-1)].instantiate()
			var tile = tiles.pop_front().instantiate()
			if tile.has_method("end_turn"):
				if tile.has_signal("create_tile_near"):
					tile.connect("create_tile_near", _on_create_tile_near)
			tile.set_tile_coord(Vector2i(i,j))
			tile.position = board.map_to_local(Vector2i(i,j))
			tile.connect("tile_pressed", on_tile_pressed)
			tile.connect("tile_hovered", on_tile_hovered)
			board.add_child(tile)
			tile.drop_animation()
			await get_tree().create_timer(0.2).timeout
	await get_tree().create_timer(0.1).timeout
	emit_signal("board_ready")
	$CanvasLayer/TurnPanel.set_text("Tour "+ str(turn_count+1))
	$CanvasLayer/TurnPanel.anim_fade()
	$CanvasLayer/Panneau.anim_fade()



func show_tooltip( text):
	%Tooltip.clear()
	%Tooltip.append_text(text)
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(%Tooltip, "modulate", Color( 1, 1, 1, 1 ), 0.2 )
	
func hide_tooltip():
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(%Tooltip, "modulate", Color( 1, 1, 1, 0 ), 0.2 )

func apply_side_effect():
	var tiles_list = []
	#parcourir les tuiles (children)
	for tile in board.get_children():
		if tile != null:
			if tile.modifiers.side_effect_modifier !=0 and !tile.side_effect_applied:
				tiles_list = [tile.tile_coord+Vector2i(-1,0),tile.tile_coord+Vector2i(1,0),tile.tile_coord+Vector2i(0,-1),tile.tile_coord+Vector2i(0,+1)]
				for subtile in board.get_children():
					if subtile.tile_coord in tiles_list:
						tiles_list.erase(subtile.tile_coord)
						var mod = Modifiers.new()
						mod.pollution_modifier = tile.modifiers.side_effect_modifier
						subtile.add_modifier(mod, null)
						tile.side_effect_applied = true
			await get_tree().create_timer(0.1).timeout
		
	await get_tree().create_timer(1.0).timeout
	
			
			
func pick_modifiers():
	for i in range(modifier_available):
		var mod = modifiers[randi_range(0,modifiers.size()-1)].instantiate()
		mod.position = modmarkers[i].position
		mod.connect("hovered", _on_modfier_hovered)
		mod.connect("dropped", _on_modfier_dropped)
		mod.connect("grabbed", _on_modfier_grabbed)
		$board.add_child(mod)
		await get_tree().create_timer(0.5).timeout
		
	if !modifier_picked_twice:
		$CanvasLayer/new_pick.anim_pop()
		$CanvasLayer/new_pick.enable = true

func check_board():
	var score = 0
	var tiles = board.get_children()
	for tile in tiles:
		score += tile.modifiers.pollution_modifier
	
	return score
	
func end_turn():
	#check board
	var result = check_board()
	for tile in board.get_children():
		tile.make_highlight()
		await get_tree().create_timer(0.1).timeout
		
	$CanvasLayer/Score.set_text(str(result) + " pts")
	$CanvasLayer/Score.anim_fade()
	
	#then show score
	if result < 0:
		$CanvasLayer/Score.set_color( Color.BROWN)
		game_over = true
	else:
		$CanvasLayer/Score.set_color( Color.CHARTREUSE)
	
	gameState = gameStates.WAITING_FOR_INPUT
	$CanvasLayer/EndTurn.enable = true
	$CanvasLayer/EndTurn.anim_pop()
	
func process_board_evolution():
	print("board evol")
	for tile in board.get_children():
		if tile.has_method("end_turn"):
			tile.end_turn()

	await get_tree().create_timer(2.0).timeout
	

func get_tile_from_map_coord(coord: Vector2i):
	var tiles = board.get_children()
	for tile in tiles:
		if tile != null and tile.tile_coord == coord:
			return tile

func _on_modfier_grabbed():
	$CanvasLayer/new_pick.anim_depop()
	$CanvasLayer/new_pick.enable = false

func _on_modfier_hovered(entity):
	if entity != null:
		var full_text ="Effet: %s"
		if entity.vegetalisation:
			full_text = "Effet: Réduit le malus d'une ville à [color=green]0[/color]"
		elif entity.reforestation:
			full_text = "Effet: plante une graine qui germe en Forêt sous 2 tours sur une tuile Plaine"
		else:
			full_text = "Effet: ajoute [color=green]+1[/color] sur une tuile Plaine"

		show_tooltip(full_text)
	else:
		hide_tooltip()
		

func _on_modfier_dropped(entity):
	var map_coord = board.local_to_map(entity.position)
	if (map_coord.x < board_size and map_coord.y < board_size) and (map_coord.x >= 0 and map_coord.y >= 0):
		var tile = get_tile_from_map_coord(map_coord)
		if tile.name.contains(entity.modifiers.apply_on):
			if entity.modifiers.apply_on == "Ville" and !tile.turn_left < 0:
				tile.add_modifier(entity.modifiers, entity.get_texture(), true)
				modifier_available -= 1
				entity.visible = false
				$FXdrop.play()
				entity.queue_free()
			else:
				if entity.modifiers.reforestation:
					tile.add_modifier(entity.modifiers, null)
					modifier_available -= 1
					entity.visible = false
					$FXdrop.play()
					entity.queue_free()
				else:
					if !entity.modifiers.vegetalisation:
						tile.add_modifier(entity.modifiers, entity.get_texture())
						modifier_available -= 1
						entity.visible = false
						$FXdrop.play()
						entity.queue_free()
	await get_tree().create_timer(1.0).timeout
	if !(modifier_available > 0):
		end_turn()



func reset_board():
	apply_side_effect() #if new tiles
	modifier_picked_twice = false
	modifier_available = 3
	pick_modifiers()
	reset_tiles_numbers()
	$CanvasLayer/Score.visible = false
	gameState = gameStates.PLAYING
	
func reset_tiles_numbers():
	var tiles = board.get_children()
	for tile in tiles:
		tile.reset_numbers()

func _on_sprite_button_pressed():
	if gameState == gameStates.WAITING_FOR_INPUT:
		if game_over:
			emit_signal("restart_game")
#			get_tree().reload_current_scene()
		else:
			turn_count+=1
			$CanvasLayer/TurnPanel.set_text("Turn "+ str(turn_count))
			gameState = gameStates.INIT
			process_board_evolution()
			reset_board()
	
func _on_create_tile_near(vec, type):
	var tile_to_change
	var possible_tiles = []
	var tile_vec
	var tile_type
	
	if type == "ville":
		if (vec+Vector2i(1,0)).x < 5 and (vec+Vector2i(1,0)).y <5:
			possible_tiles.append(vec+Vector2i(1,0))
		if (vec+Vector2i(-1,0)).x >= 0 and (vec+Vector2i(-1,0)).y >=0:
			possible_tiles.append(vec+Vector2i(-1,0))
		if (vec+Vector2i(0,1)).x < 5 and (vec+Vector2i(0,1)).y <5:
			possible_tiles.append(vec+Vector2i(0,1))
		if (vec+Vector2i(0,-1)).x >=0 and (vec+Vector2i(0,-1)).y >=0:
			possible_tiles.append(vec+Vector2i(0,-1))
			
		possible_tiles.shuffle()
		tile_vec = possible_tiles.pop_front()
		tile_to_change = get_tile_from_map_coord(tile_vec)
		while (!tile_to_change.name.contains("Plaine") or (tile_to_change.name.contains("Plaine") and tile_to_change.growing )) and possible_tiles != []:
			tile_vec = possible_tiles.pop_front()
			tile_to_change = get_tile_from_map_coord(tile_vec)
		tile_type = ville_tile	
	else:
		possible_tiles.append(vec)
		tile_vec = vec
		tile_to_change = get_tile_from_map_coord(vec)
		tile_type = foret_tile
		
	if possible_tiles != []:
		var tile_pos = tile_to_change.position
		tile_to_change.make_fall()
		var new_tile = tile_type.instantiate()
		new_tile.tile_coord = tile_vec
		new_tile.position = tile_pos
		board.add_child(new_tile)
		new_tile.drop_animation()
	else:
		get_tile_from_map_coord(vec).squash(1.4,1.4)

		
	await get_tree().create_timer(0.5).timeout
	
	
func _on_new_pick_pressed():
	$CanvasLayer/new_pick.anim_depop()
#	$CanvasLayer/new_pick.visible = false
	$CanvasLayer/new_pick.enable = false
	
	#erase old pick
	var modifiers = $board.get_children()
	for mod in modifiers:
		if mod.name.contains("Reforestation") or \
		mod.name.contains("Vegetalisation") or \
		mod.name.contains("Depoluplante"):
			mod.queue_free()
	modifier_picked_twice = true
	pick_modifiers()

	pass
