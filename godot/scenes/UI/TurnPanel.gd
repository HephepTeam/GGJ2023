extends NinePatchRect

@export var click_to_hide = false 
signal destroyed

# Called when the node enters the scene tree for the first time.
func _ready():
	modulate.a = 0
	if click_to_hide:
		anim_fade()
		

func set_text(text):
	$Label.text = text
	
func set_color(color):
	$Label.modulate = color

func anim_fade():
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate",Color(1,1,1,1), 0.5 )

func anim_fade_out():
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate",Color(1,1,1,0), 0.5 )
	if click_to_hide:
		await tween.finished
		emit_signal("destroyed")
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if click_to_hide:
			anim_fade_out()
			
