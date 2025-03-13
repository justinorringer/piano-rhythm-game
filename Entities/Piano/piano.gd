extends Node3D

@onready var start_time = Time.get_ticks_msec()
@onready var first_note_time
var tempo
@export var notes = []
var note_start_times = {} # queue to record when a note (say C) was last pressed

signal handle_notes()

func _ready():
	# get all the children and subscribe to the key_pressed signal
	for c in get_children():
		if not is_instance_of(c, PianoKey):
			return
		c.key_pressed.connect(key_pressed)
		c.key_released.connect(key_released)

# note here is index starting with C as 1
func key_pressed(note):
	var curr = Time.get_ticks_msec()
	if not first_note_time:
		first_note_time = curr
	note_start_times.note = curr

var note_names = {
	1: "C",
	2: "C#",
	3: "D",
	4: "Eb",
	5: "E",
	6: "F",
	7: "F#",
	8: "G",
	9: "G#",
	10: "A",
	11: "Bb",
	12: "B"
}
func key_released(note):
	var note_duration_sec = (Time.get_ticks_msec() - note_start_times.note) * 0.001
	var note_dict = {
		"name": note_names[note],
		"length_sec": note_duration_sec,
		"start_sec": note_start_times.note * 0.001
	}
	notes.push_back(note_dict)
	handle_notes.emit(note_dict)
	note_start_times.erase(note)
