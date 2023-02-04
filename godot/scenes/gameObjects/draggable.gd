extends Area2D

var hovered = false
var grabbed = false

signal dropped(entity)

var pollution_modifier = 2

const hovered_offset = 0.3

@onready var start_pos = global_position

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


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


func _on_mouse_exited():
	hovered = false
