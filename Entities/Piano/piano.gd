extends Node3D

@onready var start_time = Time.get_ticks_msec()
@onready var first_note_time
var tempo = 120
@export var notes : Array = []
var note_start_times = {} # queue to record when a note (say C) was last pressed
var latest_release = 0
var generator_triggered = false

signal handle_notes()

func _ready():
	# get all the children and subscribe to the key_pressed signal
	for c in get_children():
		if not is_instance_of(c, PianoKey):
			return
		c.key_pressed.connect(key_pressed)
		c.key_released.connect(key_released)


func _process(_delta):
	# should the game start?
	var curr_time = Time.get_ticks_msec()
	if notes.size() <= 3:
		return

	print(note_start_times)
	if note_start_times.is_empty():
		if not generator_triggered and (curr_time - latest_release) > 1000:
			Generator.generate(notes, tempo)
			generator_triggered = true
			get_parent()._on_generate()


func key_pressed(note):
	var curr = Time.get_ticks_msec()
	if not first_note_time:
		first_note_time = curr
	note_start_times[note] = curr
	light_note(note, true)  # testing

func light_note(note_number, is_lit: bool):
	for c in get_children():
		if is_instance_of(c, PianoKey) and c.key_index == note_number:
			if is_lit:
				c.light_note(true)
			else:
				c.light_note(false)
			return

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
	var release_msec = Time.get_ticks_msec()
	latest_release = release_msec
	var note_duration_sec = (release_msec - note_start_times[note]) * 0.001
	var note_dict = {
		"name": note_names[note],
		"length_sec": note_duration_sec,
		"start_sec": note_start_times[note] * 0.001,
		"release_sec": release_msec * 0.001
	}
	notes.push_back(note_dict)
	note_start_times.erase(note)
	update_durations_and_tempo()
	handle_notes.emit(note_dict)
	light_note(note, false) # testing


var note_lengths = {
	#8.0: "tied whole",
	#6.0: "dotted whole",
	4.0: "whole",
	3.0: "dotted half",
	2.0: "half",
	1.5: "dotted quarter",
	1.0: "quarter",
	0.5: "eighth",
	0.25: "sixteenth"
}
func categorize_note_length(interval: float, bpm: float) -> String:
	var beat_duration = 60.0 / bpm  # Time duration of one beat in seconds

	var interval_in_beats = interval / beat_duration
	var error = 0.3
	if abs(interval_in_beats - 4.0) > error:
		return note_lengths[4.0]
	for key in note_lengths:
		if abs(interval_in_beats - key) < error:
			return note_lengths[key]

	return "quarter" # at the worst...


func update_durations_and_tempo():
	var intervals = []
	var interval_sum = 0.0
	var categorized_notes = []
	
	for i in range(1, notes.size()+1):
		var start_sec = notes[i-1].start_sec
		var next_start_time = notes[i-1].release_sec
		if notes.size() > i:
			next_start_time = notes[i].release_sec
		var interval = next_start_time - start_sec
		
		interval_sum += interval
		intervals.append(interval)
		
		var note_length = categorize_note_length(interval, tempo)  # Assume 120 BPM for now
		notes[i-1]["length"] = note_length
		# TODO trigger signal if note is updated
		categorized_notes.push_back(notes[i-1])
	
	var avg_interval = 0.0
	if intervals.size() > 0:
		avg_interval = interval_sum / intervals.size()
	
	tempo = 60 / avg_interval
	notes = categorized_notes
