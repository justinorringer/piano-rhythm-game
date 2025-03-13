extends Node

@export var _main_ready = false
@export var _keyboard_ready = false
var csound: CsoundGodot
var midi_csd = "res://midi.csd"

func _ready():
	CsoundServer.connect("csound_layout_changed", csound_layout_changed)


func csound_layout_changed():
	sub_csound_ready("Main", csound_ready_main)
	sub_csound_ready("Keyboard", csound_ready_keyboard)


func sub_csound_ready(csound_name, function):
	csound = CsoundServer.get_csound(csound_name)
	csound.send_control_channel("cutoff", 1)
	csound.csound_ready.connect(function)


signal csound_ready_keyboard_signal()
func csound_ready_keyboard(csound_name):
	if csound_name != "Keyboard":
		return
	_keyboard_ready = true
	csound.compile_csd(FileAccess.get_file_as_string(midi_csd))
	csound_ready_keyboard_signal.emit()


signal csound_ready_main_signal()
func csound_ready_main(csound_name):
	if csound_name != "Main":
		return
	_main_ready = true
	csound_ready_main_signal.emit()
