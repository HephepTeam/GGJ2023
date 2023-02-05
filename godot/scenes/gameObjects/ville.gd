extends Tuile

signal create_tile_near(vec, type)

var turn_left = 1


func end_turn():
	if turn_left > 0:
		turn_left -= 1
	if turn_left == 0:
		#evolution
		emit_signal("create_tile_near", tile_coord, "ville")
		
func add_modifier(mod,spr_mod, vg = false):
	super.add_modifier(mod,spr_mod)
	if vg:
		$Spr.texture = load("res://assets/graphics/modifier/Tuile_Ville__vg.png")
		turn_left = -1
		%Modifiers.pollution_modifier =0 


