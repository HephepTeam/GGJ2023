class_name Tuile
extends Node2D



signal tile_pressed(coord : Vector2)

var tile_coord = Vector2i() : set = set_tile_coord

@export var apply_on = ""
@export var pollution_modifier = 0
@export var side_effect_modifier = 0
@export var turn_modifier = 0

func set_tile_coord(new_coord):
	tile_coord = new_coord

var hovered = false
var falling = false
var fading = false

var amplitude = 0 as float

const hovered_offset = -32.0
const falling_offset = 2000.0
var modifiers = null

func _ready():
	%Modifiers.initialize(pollution_modifier, side_effect_modifier, turn_modifier, apply_on)
	modifiers = %Modifiers

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Spr.scale = lerp($Spr.scale, Vector2(1,1), 0.2)
	if !falling:
		if hovered:
			$Spr.position.y = lerp($Spr.position.y , hovered_offset, 0.2)	
		else:
			$Spr.position.y = lerp($Spr.position.y, 0.0, 0.2)
			
	$Spr/Label.text = "[center][shake rate="+str(amplitude)+" level="+str(amplitude)+"]"+str(%Modifiers.pollution_modifier)+"[/shake][/center]"
	
	if !fading:
		if %Modifiers.pollution_modifier >= 0: 
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
	
func drop_animation():
	$Spr.position.y -= falling_offset 
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property($Spr, "position", $Spr.position + Vector2(0,falling_offset), 1.0 )
	
func make_highlight():
	fading = true
	squash(1.4,1.4)
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property($Spr/Label, "position", $Spr/Label.position - Vector2(0,50), 1.0 )
	tween.parallel().tween_property($Spr/Label, "modulate", Color( 1, 1, 1, 0 ), 1.0 )
	
func reset_visual():
	fading = false
	
	
func add_modifier(mod,spr_mod):
	if spr_mod != null:
		var texture = TextureRect.new()
		texture.mouse_filter=Control.MOUSE_FILTER_IGNORE
		texture.texture = spr_mod
		$Spr/mod_icons.add_child(texture)
	$Timer.start()
	amplitude = 15
	%Modifiers.pollution_modifier += mod
	
func get_side_effect():
	return modifiers["side_effect"]
		
func _on_timer_timeout():
	amplitude = 0
