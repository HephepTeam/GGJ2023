extends Node

var game = null

var tuto_seen = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func start_music():
	if !$Music.playing:
		$Music.play()
