extends Tuile

var growing = false
signal create_tile_near(vec, type)

var turn_left = -1 

func end_turn():
	if growing:
		turn_left -= 1
		if turn_left == 0:
			#evolution
			#change sprite and Modifiers to become a forest
			make_fall()
			emit_signal("create_tile_near", tile_coord, "foret")

		
func add_modifier(mod,spr_mod):
	super.add_modifier(mod,spr_mod)
	if mod.reforestation == true:
		growing = true
		$Spr/flag.visible = true
		turn_left = 2
		
