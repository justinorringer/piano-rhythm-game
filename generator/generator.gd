extends Node2D

var csound: CsoundGodot

@onready var csd = 'res://piano.csd'

func generate(notes) -> void:
	if not CsoundState._main_ready:
		await get_tree().create_timer(1.0).timeout
		generate(notes)
		return
	csound = CsoundServer.get_csound("Main")
	csound.compile_csd(FileAccess.get_file_as_string(csd))
	var scale_notes = [261, 277, 293, 311, 329, 349, 369, 392, 415, 440]
	for i in range(10):
		# an arg is wrong but you get the idea
		# first arg is seconds from the current time.
		var event = 'i "piano" %d 1 %d 0.09 %d' % [i, i, scale_notes[i]]
		csound.event_string(event)

	await get_tree().create_timer(10.0).timeout
