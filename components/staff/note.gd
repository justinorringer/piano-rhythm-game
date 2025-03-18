class_name Note extends Area2D

@onready var sprite = $Sprite2D

var color_map = {
	"C": Color(1.0, 0.0, 0.0),
	"C#": Color(1.0, 0.486, 0.0),
	"D": Color(1.0, 1.0, 0.0),
	"D#": Color(0.486, 1.0, 0.0),
	"Eb": Color(0.486, 1.0, 0.0),
	"E": Color(0.0, 1.0, 0.0),
	"F": Color(0.0, 1.0, 0.486),
	"F#": Color(0.0, 1.0, 1.0),
	"G": Color(0.0, 0.486, 1.0),
	"G#": Color(0.0, 0.0, 1.0),
	"A": Color(0.486, 0.0, 1.0),
	"Bb": Color(1.0, 0.0, 1.0),
	"B": Color(1.0, 0.0, 0.486)
}


func change_color(name):
	sprite.modulate = color_map[name]
