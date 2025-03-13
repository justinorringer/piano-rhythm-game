extends Node2D

@export var _main_ready = false
@export var _keyboard_ready = false
var csound: CsoundGodot
var midi_csd = "res://midi.csd"


func _ready():
	CsoundServer.connect("csound_layout_changed", csound_layout_changed)


func csound_layout_changed():
	csound = CsoundServer.get_csound("Keyboard")
	csound.send_control_channel("cutoff", 1)
	csound.csound_ready.connect(csound_ready)
	
	csound = CsoundServer.get_csound("Main")
	csound.send_control_channel("cutoff", 1)
	csound.csound_ready.connect(csound_ready)


func csound_ready(csound_name):
	if csound_name == "Keyboard":
		_keyboard_ready = true
	if csound_name == "Main":
		_main_ready = true
		csound.compile_csd(FileAccess.get_file_as_string(midi_csd))
