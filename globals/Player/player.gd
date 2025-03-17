extends Node

@onready var csd = 'res://piano.csd'
var csound: CsoundGodot

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
func play(notes, tempo) -> void:
	if not CsoundState._main_ready:
		await get_tree().create_timer(1.0).timeout
		play(notes, tempo)
		return
	csound = CsoundServer.get_csound("Main")
	csound.compile_csd(FileAccess.get_file_as_string(csd))

	var note_frequencies = {
		"C": 261.63,
		"C#": 277.18,
		"D": 293.66,
		"D#": 311.13,
		"Eb": 311.13,
		"E": 329.63,
		"F": 349.23,
		"F#": 369.99,
		"G": 392.00,
		"G#": 415.30,
		"A": 440.00,
		"Bb": 466.16,
		"B": 493.88
	}

	var beat_duration = 60.0 / tempo  # Duration of one beat in seconds
	for note in notes:
		var note_name = note["name"]
		if note_name == "R":
			continue
		var start_sec = note["start_count"] * beat_duration
		var length_sec = note_lengths.find_key(note["length"]) * beat_duration
		var frequency = note_frequencies[note_name]* pow(2, note["octave"] - 4)
		# octave = 4 => freq = freq * 2^0
		# octave = 5 => freq = freq * 2^1
		# octave = 3 => freq = freq * 2^(-1)
		
		# Generate the main note event
		#i101100  1   0.2 349/2 0.01 0.75 100 100
		var event = 'i "synth" %f %f %f %f %f %f %f %f' % [start_sec, length_sec, 0.2, frequency, 0.01, 0.75, 100, 100]
		csound.event_string(event)

	await get_tree().create_timer(60.0).timeout
