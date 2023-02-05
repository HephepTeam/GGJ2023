extends Area2D

signal pressed
signal init_finished

var enable = false
var hovered = false

const hovered_offset = 0.2
# Called when the node enters the scene tree for the first time.
func _ready():
	$Spr.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hovered:
		$Spr.scale = lerp($Spr.scale , Vector2(1+hovered_offset,1+hovered_offset), 0.2)	
	else:
		$Spr.scale = lerp($Spr.scale, Vector2(1,1), 0.2)
		
func anim_pop():
	$Spr.scale = Vector2(0.1,0.1)
	$Spr.visible = true
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($Spr, "scale",Vector2(1,1), 1.0 )
	await tween.finished
	emit_signal("init_finished")
	
func anim_depop():
	enable = false
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property($Spr, "scale",Vector2(0.1,0.1), 0.5 )
	await tween.finished
	$Spr.visible = false



func _on_input_event(viewport, event, shape_idx):
	if enable:
		if (event is InputEventMouseMotion):
			if !hovered:
				hovered = true

		if (event is InputEventMouseButton) and hovered:
			if event.is_pressed():
				get_viewport().set_input_as_handled()
				emit_signal("pressed")
				$FXclic.play()
				anim_depop()
				
func retry_mode():
	$Spr.texture = load("res://assets/graphics/try_again.png")


func _on_mouse_exited():
	hovered = false


