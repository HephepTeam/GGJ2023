extends Area2D

signal pressed

var hovered = false
const hovered_offset = 0.2
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hovered:
		$Spr.scale = lerp($Spr.scale , Vector2(1+hovered_offset,1+hovered_offset), 0.2)	
	else:
		$Spr.scale = lerp($Spr.scale, Vector2(1,1), 0.2)


func _on_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseMotion):
		if !hovered:
			hovered = true
			
	if (event is InputEventMouseButton) and hovered:
		if event.is_pressed():
			emit_signal("pressed")


func _on_mouse_exited():
	hovered = false
