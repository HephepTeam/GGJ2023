class_name Tuile
extends Node2D

signal tile_pressed(coord : Vector2)

var tile_coord = Vector2i() : set = set_tile_coord
@export var pollution_modifier = 0

func set_tile_coord(new_coord):
	tile_coord = new_coord

var hovered = false
var falling = false

var amplitude = 0 as float

const hovered_offset = -32.0
const falling_offset = 2000.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Spr.scale = lerp($Spr.scale, Vector2(1,1), 0.2)
	if !falling:
		if hovered:
			$Spr.position.y = lerp($Spr.position.y , hovered_offset, 0.2)	
		else:
			$Spr.position.y = lerp($Spr.position.y, 0.0, 0.2)
			
	$Spr/Label.text = "[center][shake rate="+str(amplitude)+" level="+str(amplitude)+"]"+str(pollution_modifier)+"[/shake][/center]"
	
	if pollution_modifier >= 0: 
		$Spr/Label.modulate = Color.CHARTREUSE
	else:
		$Spr/Label.modulate = Color.BROWN
			



func _on_area_2d_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseMotion):
		if !hovered:
			hovered = true
			
	if event is InputEventMouseButton:
		if event.is_pressed() and !falling:
			emit_signal("tile_pressed", tile_coord)
			squash(1.4,1.4)

			
func squash(x,y):
	$Spr.scale.x = x
	$Spr.scale.y = y
	

func _on_area_2d_mouse_exited():
	hovered = false
		
func make_fall():
	falling = true
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property($Spr, "position", $Spr.position + Vector2(0,falling_offset), 1.0 )
	tween.tween_callback(queue_free)
	
func add_modifier(mod):
	$Timer.start()
	amplitude = 15
	pollution_modifier += mod
		
func _on_timer_timeout():
	amplitude = 0
