extends NinePatchRect


# Called when the node enters the scene tree for the first time.
func _ready():
	modulate.a = 0

func append_text(text):
	$RichTextLabel.append_text(text)
	
func clear():
	$RichTextLabel.clear()

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
