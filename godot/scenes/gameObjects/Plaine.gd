extends Tuile

var growing = false

var turn_left = -1 

func end_turn():
	if growing:
		turn_left -= 1
		if turn_left == 0:
			#evolution
			#change sprite and Modifiers to become a forest
			$Spr.texture = load("res://assets/graphics/modifier/Tuile_foret.png")
			%Modifiers.pollution_modifier =2
			%Modifiers.side_effect_modifier = 1
		
func add_modifier(mod,spr_mod):
	super.add_modifier(mod,spr_mod)
	if mod.reforestation == true:
		growing = true
		turn_left = 2
		
