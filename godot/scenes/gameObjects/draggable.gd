extends Area2D

var hovered = false
var grabbed = false

@export_file  var tiny_icon = "res://assets/graphics/modifier/Fleur_Dépolluante_icon.png"

signal dropped(entity)
@export var apply_on = ""
@export var pollution_modifier = 0
@export var side_effect_modifier = 0
@export var turn_modifier = 0
var modifiers = null

const hovered_offset = 0.3

@onready var start_pos = global_position

# Called when the node enters the scene tree for the first time.
func _ready():
	%Modifiers.initialize(pollution_modifier,side_effect_modifier,turn_modifier, apply_on)
	modifiers = %Modifiers


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hovered:
		$Spr.scale = lerp($Spr.scale , Vector2(1+hovered_offset,1+hovered_offset), 0.2)	
	else:
		$Spr.scale = lerp($Spr.scale, Vector2(1,1), 0.2)
		
	if grabbed:
		global_position = get_global_mouse_position()
	else:
		global_position = lerp(global_position, start_pos, 0.5)


func _on_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseMotion):
		if !hovered:
			hovered = true
			
	if (event is InputEventMouseButton) and hovered:
		if event.is_pressed():
			grabbed = true
		else:
			emit_signal("dropped", self)
			grabbed = false

func get_texture():
	return load(tiny_icon)

func _on_mouse_exited():
	hovered = false
