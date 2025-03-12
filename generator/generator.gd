extends Node2D

var csound: CsoundGodot

@onready var csd = 'res://piano.csd'

func _ready():
	CsoundServer.connect("csound_layout_changed", csound_layout_changed)


func csound_layout_changed():
	csound = CsoundServer.get_csound("Main")
	csound.send_control_channel("cutoff", 1)

	csound.csound_ready.connect(csound_ready)


func csound_ready(csound_name):
	if csound_name != "Main":
		return
	_generate()


func _generate() -> void:
	csound.compile_csd(FileAccess.get_file_as_string(csd))
	var notes = [261, 277, 293, 311, 329, 349, 369, 392, 415, 440]
	for i in range(10):
		# an arg is wrong but you get the idea
		# first arg is seconds from the current time.
		var event = 'i "piano" %d 1 %d 0.09 %d' % [i, i, notes[i]]
		csound.event_string(event)

	await get_tree().create_timer(10.0).timeout
