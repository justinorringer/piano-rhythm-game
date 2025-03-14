extends Control

var current_time: float = 0.0
@onready var notes = $NoteControl.get_children()

func _process(delta):
	current_time += delta
	for note in notes:
		note.get_child(0).update_position(current_time)
