extends Node3D

@onready var start_time = Time.get_ticks_msec()
@onready var first_note_time
var tempo = 120
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
	var release_sec = Time.get_ticks_msec()
	var note_duration_sec = (release_sec - note_start_times.note) * 0.001
	var note_dict = {
		"name": note_names[note],
		"length_sec": note_duration_sec,
		"start_sec": note_start_times.note * 0.001,
		"release_sec": release_sec * 0.001
	}
	notes.push_back(note_dict)
	update_durations_and_tempo()
	handle_notes.emit(note_dict)
	note_start_times.erase(note)

var note_lengths = {
	6.0: "dotted whole",
	4.0: "whole",
	3.0: "dotted half",
	2.0: "half",
	1.5: "dotted quarter",
	1.0: "quarter",
	0.5: "eighth",
	0.25: "sixteenth"
}
func categorize_note_length(interval: float, tempo: float) -> String:
	var beat_duration = 60.0 / tempo  # Time duration of one beat in seconds

	var interval_in_beats = interval / beat_duration
	var error = 0.3
	for key in note_lengths:
		if abs(interval_in_beats - key) < 0.4:
			return note_lengths[key]

	print("interval in beats", interval_in_beats)
	return "quarter" # at the worst...


# Main function to calculate the tempo and categorize note lengths
func update_durations_and_tempo():
	var intervals = []
	var interval_sum = 0.0
	var categorized_notes = []
	
	for i in range(1, notes.size()):
		var start_time = notes[i-1].start_sec
		var next_start_time = notes[i].release_sec
		var interval = next_start_time - start_time
		print("interval", interval)
		interval_sum += interval
		intervals.append(interval)
		
		var note_length = categorize_note_length(interval, tempo)  # Assume 120 BPM for now
		categorized_notes.append(note_length)
	
	var avg_interval = 0.0
	if intervals.size() > 0:
		avg_interval = interval_sum / intervals.size()
	
	# Estimate the BPM
	tempo = 60 / avg_interval
	print({"tempo": tempo, "categorized_notes": categorized_notes})
