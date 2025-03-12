extends Node3D

@export var key_index: int = 0
@export var blackKey: bool = false
@onready var anim_player = $AnimationPlayer
@onready var mesh = $MeshInstance3D
@onready var midi_csd = "res://midi.csd"

var _csound_ready = false
var csound: CsoundGodot

func _ready():
	CsoundServer.connect("csound_layout_changed", csound_layout_changed)


func csound_layout_changed():
	csound = CsoundServer.get_csound("Keyboard")
	csound.send_control_channel("cutoff", 1)

	csound.csound_ready.connect(csound_ready)


func csound_ready(csound_name):
	if csound_name != "Keyboard":
		return
	_csound_ready = true
	csound.compile_csd(FileAccess.get_file_as_string(midi_csd))

enum KeyState { OFF, ON }
var state = KeyState.OFF

var key_map = {
	1: KEY_A,  2: KEY_W,  3: KEY_S,  4: KEY_E,  
	5: KEY_D,  6: KEY_F,  7: KEY_T,  8: KEY_G,  
	9: KEY_Y, 10: KEY_H, 11: KEY_U, 12: KEY_J
}

func set_state(new_state: KeyState):
	if state != new_state:
		state = new_state
		match state:
			KeyState.OFF:
				anim_player.play("off")
			KeyState.ON:
				anim_player.play("on")

func _input(event):
	if not _csound_ready:
		return
		
	if event is InputEventKey and key_index in key_map:
		if event.keycode == key_map[key_index]:
			if event.pressed:
				if state == KeyState.ON:
					return
				csound.note_on(0, 67 + key_index, 90)
				#csound.note_on(key_index, key_index + 100, 90)
				set_state(KeyState.ON)
			else:
				csound.note_off(0, 67 + key_index)
				#csound.note_off(key_index, key_index + 100)
				set_state(KeyState.OFF)
