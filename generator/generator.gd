extends Node2D

var csound: CsoundGodot

@onready var csd = 'res://piano.csd'

func generate(notes, tempo) -> void:
	if not CsoundState._main_ready:
		await get_tree().create_timer(1.0).timeout
		generate(notes, tempo)
		return
	csound = CsoundServer.get_csound("Main")
	csound.compile_csd(FileAccess.get_file_as_string(csd))
	#var scale_notes = [261, 277, 293, 311, 329, 349, 369, 392, 415, 440]
	#for i in range(10):
		## an arg is wrong but you get the idea
		## first arg is seconds from the current time.
		#var event = 'i "piano" %d 1 %d 0.09 %d' % [i, i, scale_notes[i]]
		#csound.event_string(event)

	#await get_tree().create_timer(10.0).timeout

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
	
	var chords = {
		"C": ["C", "E", "G"],
		"D": ["D", "F#", "A"],
		"E": ["E", "G#", "B"],
		"F": ["F", "A", "C"],
		"G": ["G", "B", "D"],
		"A": ["A", "C#", "E"],
		"B": ["B", "D#", "F#"]
	}
	
	var current_time = 0.0
	var piece_length = 60.0  # Length of the piece in seconds
	var beat_duration = 60.0 / tempo  # Duration of one beat in seconds
	
	while current_time < piece_length:
		for note in notes:
			var note_name = note["name"]
			var length_sec = note["length_sec"]
			var frequency = note_frequencies[note_name]
			
			# Generate the main note event
			#i101    100          1   0.2                 349/2                 0.01 0.75 100 100
			var event = 'i "synth" %f %f %f %f %f %f %f %f' % [current_time, length_sec, 0.2, frequency, 0.01, 0.75, 100, 100]
			csound.event_string(event)
			
			# Generate the chord events
			if note_name in chords:
				for chord_note in chords[note_name]:
					var chord_frequency = note_frequencies[chord_note]
					var chord_event = 'i "synth" %f %f %f %f %f %f %f %f' % [current_time, length_sec, 0.2, chord_frequency, 0.01, 0.75, 100, 100]
					csound.event_string(chord_event)
			
			current_time += length_sec
	
	await get_tree().create_timer(piece_length).timeout
