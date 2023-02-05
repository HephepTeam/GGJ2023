extends Area2D

var is_hovered = false
var is_grabbed = false
var init = true

signal init_finished
signal grabbed
signal hovered(entity)

@export_file  var tiny_icon = "res://assets/graphics/modifier/Fleur_Dépolluante_icon.png"

signal dropped(entity)
@export var vegetalisation = false
@export var reforestation = false
@export var apply_on = ""
@export var pollution_modifier = 0
@export var side_effect_modifier = 0
@export var turn_modifier = 0
var modifiers = null

const hovered_offset = 0.3

@onready var start_pos = global_position

# Called when the node enters the scene tree for the first time.
func _ready():
	%Modifiers.initialize(pollution_modifier,side_effect_modifier,turn_modifier, apply_on,vegetalisation,reforestation)
	modifiers = %Modifiers
	
	anim_pop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !init:
		if is_hovered:
			$Spr.scale = lerp($Spr.scale , Vector2(1+hovered_offset,1+hovered_offset), 0.2)	
		else:
			$Spr.scale = lerp($Spr.scale, Vector2(1,1), 0.2)
			
		if is_grabbed:
			global_position = get_global_mouse_position()
		else:
			global_position = lerp(global_position, start_pos, 0.5)

func anim_pop():
	$Spr.scale = Vector2(0.1,0.1)
	$Spr.visible = true
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($Spr, "scale",Vector2(1,1), 1.0 )
	await tween.finished
	emit_signal("init_finished")
	init = false

func _on_input_event(viewport, event, shape_idx):
	if Globals.game.gameState == Globals.game.gameStates.PLAYING:
		if (event is InputEventMouseMotion):
			if !is_hovered:
				is_hovered = true
				emit_signal("hovered", self)
				
		if (event is InputEventMouseButton) and is_hovered:
			if event.is_pressed():
				is_grabbed = true
				emit_signal("grabbed")
			else:
				emit_signal("dropped", self)
				is_grabbed = false

func get_texture():
	return load(tiny_icon)

func _on_mouse_exited():
	is_hovered = false
	emit_signal("hovered", null)
