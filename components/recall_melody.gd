extends Node

@onready var staff = $"../CanvasLayer/Staff"
var note_timer = preload("res://components/staff/note_timer.tscn")
var queue = []

func _ready():
	if not GameState.melody:
		print("no melody found")
		return
	
	var note_lengths = {
		8.0: "tied whole",
		6.0: "dotted whole",
		4.0: "whole",
		3.0: "dotted half",
		2.0: "half",
		1.5: "dotted quarter",
		1.0: "quarter",
		0.5: "eighth",
		0.25: "sixteenth"
	}
	
	var beat_duration = 60.0 / GameState.tempo  # Duration of one beat in seconds
	for note in GameState.melody:
		var note_name = note["name"]
		if note_name == "R":
			continue
		var start_sec = note["start_count"] * beat_duration
		var trigger_sec = (note["start_count"] - 18) * beat_duration
		var length_sec = note_lengths.find_key(note["length"]) * beat_duration
		
		var timer = note_timer.instantiate()
		timer.note = note_name
		timer.length_sec = length_sec
		timer.start_count = note["start_count"]
		add_child(timer)
		timer.queue_note(staff.spawn_note, trigger_sec)
