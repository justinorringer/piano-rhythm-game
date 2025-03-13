extends Node2D

var csound: CsoundGodot

@onready var csd = 'res://piano.csd'

func _ready():
	if CsoundState._main_ready:
		_generate()
	else:
		CsoundState.csound_ready_main_signal.connect(csound_ready)


func csound_ready():
	_generate()


func _generate() -> void:
	csound = CsoundServer.get_csound("Main")
	csound.compile_csd(FileAccess.get_file_as_string(csd))
	var notes = [261, 277, 293, 311, 329, 349, 369, 392, 415, 440]
	for i in range(10):
		# an arg is wrong but you get the idea
		# first arg is seconds from the current time.
		var event = 'i "piano" %d 1 %d 0.09 %d' % [i, i, notes[i]]
		csound.event_string(event)

	await get_tree().create_timer(10.0).timeout
