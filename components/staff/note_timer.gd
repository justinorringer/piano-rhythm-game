class_name NoteTimer extends Node2D

@export var note = "C"
@export var length_sec = 0.0
@export var start_count = 0.0

func queue_note(callback: Callable, time_left):
	await get_tree().create_timer(time_left).timeout
	
	callback.call(note)
	queue_free()
