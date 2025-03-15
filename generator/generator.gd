extends Node2D
const MAX_SONG_LENGTH = 30 # short and sweet?

var csound: CsoundGodot

@onready var csd = 'res://piano.csd'

func generate(lick, tempo):
	var licky = lick
	# pick chords using generate_chords()
	var chords = generate_chord_progression(lick)
	chords = pick_chord_relation(chords)
	# create a note pool for melodic lines
	var note_pool = lick
	# add similar notes to the pool as well
	for chord_info in chords:
		print("Chord info", chord_info)
		note_pool.append({"name": RNG.pick_random(chord_info["triad"]), "length": "quarter"})
	RNG.shuffle(note_pool)

	# generate phrases similar to the lick provided
	var phrases = [licky, licky]
	for i in range(4):  # Generate 4 phrases
		var phrase = []
		for j in range(lick.size() - 1):
			var random_note = note_pool[randi() % note_pool.size()]
			phrase.append(random_note)
		phrases.append(phrase)
	
	# TODO: order notes in lick to sometimes ascend or descend

	# concatenate those phrases together
	var new_melody = []
	var to_rest_or_not = [[], [{"name": "R", "length": "quarter"}]]
	for phrase in phrases:
		new_melody += phrase + RNG.pick_random(to_rest_or_not)

	new_melody = limit_notes_to_max_song_length(new_melody, tempo)
	
	var timed_chords = time_chords_with_notes(chords, new_melody)
	print("timed chords", timed_chords)

var circle_of_fifths = [
	"C", "G", "D", "A", "E", "B", "F#", "Db", "Ab", "Eb", "Bb", "F"
]

var notes_by_step = [
	"C", "C#", "D", "Eb", "E",
	"F", "F#", "G", "G#", "A", 
	"Bb", "B", "C", "C#", "D", 
	"Eb", "E", "F", "F#", "G"
]

# Chord types (Major, Minor, etc.)
var chord_relations = {
	"major": [0, 4, 7],  # Root, Major third, Perfect fifth
	"minor": [0, 3, 7],   # Root, Minor third, Perfect fifth
	"diminished": [0, 3, 6],  # Diminished: Root, Minor third, Diminished fifth
	"augmented": [0, 4, 8]   # Augmented: Root, Major third, Augmented fifth
}

const MAX_CHORDS := 5
func generate_chord_progression(notes):
	var first = RNG.pick_random(notes).name
	var progression := [first]
	
	var dir = [1, 1, -1, -1, 0, null, null]
	var curr_direction = 0
	var curr_note = first
	var curr_index = circle_of_fifths.find(first)
	var jumps = [1, 1, 5, 5] + range(0, 6)
	while progression.size() < MAX_CHORDS:
		var direction = RNG.pick_random(dir)
		var jump = RNG.pick_random(jumps)
		
		if direction == null:
			# means continue the same direction
			direction = curr_direction

		var next_index = curr_index + (direction * jump)

		if next_index > 0:
			next_index = next_index % 12
		var next_note = circle_of_fifths[next_index]
		
		# TODO validate no conflicts with found notes.
		progression.append(next_note)
		
		curr_direction = direction
		curr_note = next_note
		curr_index = next_index

	return progression

func pick_chord_relation(chords: Array):
	var chords_including_interval = []
	for c in chords:
		var relation = RNG.pick_random(chord_relations.keys())
		chords_including_interval.push_back({
			"chord": c,
			"relation": relation,
			"triad": _find_triad_from_relation(c, relation)
		})
	
	return chords_including_interval

func _find_triad_from_relation(chord: String, relation: String):
	var triad = []
	var intervals = chord_relations.get(relation, chord_relations["major"])
	var root_index = notes_by_step.find(chord)

	for interval in intervals:
		var note_index = (root_index + interval) % notes_by_step.size()
		triad.append(notes_by_step[note_index])

	return triad

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
func limit_notes_to_max_song_length(notes, tempo):
	# note format {"name": "R", "length": "quarter"}
	var beat_duration = 60.0 / tempo  # Duration of one beat in seconds
	var total_duration = 0.0
	var limited_notes = []

	for note in notes:
		var note_length = note["length"]
		var note_duration = note_lengths.get(note_length, 1.0) * beat_duration

		if total_duration + note_duration > MAX_SONG_LENGTH:
			break

		limited_notes.append(note)
		total_duration += note_duration

	print("total dur", total_duration)
	return limited_notes


func time_chords_with_notes(chords: Array, notes: Array):
	# assign chords length, be consistent as it repeats
	# chords formatted like [{ "chord": "F", "relation": "minor", "triad": ["F", "G#", "C"] }
	# notes like [{"name": "A", "length": "quarter"}]
	var timed_chords = []
	var chord_count = chords.size()
	var length_options = [8.0, 6.0, 4.0, 3.0, 2.0]
	var note_loop_index = 0
	var count = 1
	var carry = 0
	var song_left = true

	while song_left:
		for chord in chords:
			if note_loop_index >= notes.size():
				song_left = false
				break
			var note = notes[note_loop_index]
			var note_name = note["name"]
			var note_length = note["length"]

			# Check if any note in the triad is a half step away
			# from the note being played. could be fine, but safer
			var valid_chord = true
			for triad_note in chord["triad"]:
				var note_index = notes_by_step.find(note_name)
				var triad_note_index = notes_by_step.find(triad_note)
				if abs(note_index - triad_note_index) == 1:
					valid_chord = false
					break

			if valid_chord:
				var random_length = RNG.pick_random(length_options)
				var timed_chord = chord.duplicate()
				timed_chord["length"] = random_length
				timed_chord["start_count"] = count
				
				# move count and note_loop_index up
				var tmp_count = carry # for current chord from one phrase to another
				carry = 0
				while tmp_count < random_length and note_loop_index < notes.size():
					var passed_note_length = note_lengths.find_key(notes[note_loop_index]["length"])
					count += passed_note_length
					tmp_count += passed_note_length
					note_loop_index += 1
				if tmp_count > random_length:
					note_loop_index -= 1
					carry = tmp_count - random_length
				
				timed_chords.append(timed_chord)

	return timed_chords

func count_notes(notes):
	# TODO
	pass

#func generate(notes, tempo) -> void:
	#if not CsoundState._main_ready:
		#await get_tree().create_timer(1.0).timeout
		#generate(notes, tempo)
		#return
	#csound = CsoundServer.get_csound("Main")
	#csound.compile_csd(FileAccess.get_file_as_string(csd))
	##var scale_notes = [261, 277, 293, 311, 329, 349, 369, 392, 415, 440]
	##for i in range(10):
		### an arg is wrong but you get the idea
		### first arg is seconds from the current time.
		##var event = 'i "piano" %d 1 %d 0.09 %d' % [i, i, scale_notes[i]]
		##csound.event_string(event)
#
	##await get_tree().create_timer(10.0).timeout
#
	#var note_frequencies = {
		#"C": 261.63,
		#"C#": 277.18,
		#"D": 293.66,
		#"D#": 311.13,
		#"Eb": 311.13,
		#"E": 329.63,
		#"F": 349.23,
		#"F#": 369.99,
		#"G": 392.00,
		#"G#": 415.30,
		#"A": 440.00,
		#"Bb": 466.16,
		#"B": 493.88
	#}
	#
	#var chords = {
		#"C": ["C", "E", "G"],
		#"D": ["D", "F#", "A"],
		#"E": ["E", "G#", "B"],
		#"F": ["F", "A", "C"],
		#"G": ["G", "B", "D"],
		#"A": ["A", "C#", "E"],
		#"B": ["B", "D#", "F#"]
	#}
	#
	#var current_time = 0.0
	#var piece_length = 60.0  # Length of the piece in seconds
	#var beat_duration = 60.0 / tempo  # Duration of one beat in seconds
	#
	#while current_time < piece_length:
		#for note in notes:
			#var note_name = note["name"]
			#var length_sec = note["length_sec"]
			#var frequency = note_frequencies[note_name]
			#
			## Generate the main note event
			##i101100  1   0.2 349/2 0.01 0.75 100 100
			#var event = 'i "synth" %f %f %f %f %f %f %f %f' % [current_time, length_sec, 0.2, frequency, 0.01, 0.75, 100, 100]
			#csound.event_string(event)
			#
			## Generate the chord events
			#if note_name in chords:
				#for chord_note in chords[note_name]:
					#var chord_frequency = note_frequencies[chord_note]
					#var chord_event = 'i "synth" %f %f %f %f %f %f %f %f' % [current_time, length_sec, 0.2, chord_frequency, 0.01, 0.75, 100, 100]
					#csound.event_string(chord_event)
			#
			#current_time += length_sec
	#
	#await get_tree().create_timer(piece_length).timeout
