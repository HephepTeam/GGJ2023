class_name Modifiers
extends Node

@export var apply_on = ""
@export var pollution_modifier = 0
@export var side_effect_modifier = 0
@export var turn_modifier = 0

func initialize(pm, sem, tm, ao):
	pollution_modifier = pm
	side_effect_modifier = sem
	turn_modifier = tm
	apply_on = ao
