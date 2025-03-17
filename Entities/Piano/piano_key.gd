class_name PianoKey extends Node3D

@export var key_index: int = 0
@onready var anim_player = $AnimationPlayer
@onready var mesh = $MeshInstance3D

signal key_pressed(note)
signal key_released(note)
var csound: CsoundGodot = CsoundServer.get_csound("Keyboard")

func _ready():
	CsoundState.csound_ready_keyboard_signal.connect(csound_ready)

func csound_ready():
	csound = CsoundServer.get_csound("Keyboard")

enum KeyState { OFF, ON }
var state = KeyState.OFF

var key_map = {
	1: KEY_A,  2: KEY_W,  3: KEY_S,  4: KEY_E,  
	5: KEY_D,  6: KEY_F,  7: KEY_T,  8: KEY_G,  
	9: KEY_Y, 10: KEY_H, 11: KEY_U, 12: KEY_J
}

var color_map = {
	1: Color(1.0, 0.0, 0.0),
	2: Color(1.0, 0.486, 0.0),
	3: Color(1.0, 1.0, 0.0),
	4: Color(0.486, 1.0, 0.0),
	5: Color(0.0, 1.0, 0.0),
	6: Color(0.0, 1.0, 0.486),
	7: Color(0.0, 1.0, 1.0),
	8: Color(0.0, 0.486, 1.0),
	9: Color(0.0, 0.0, 1.0),
	10: Color(0.486, 0.0, 1.0),
	11: Color(1.0, 0.0, 1.0),
	12: Color(1.0, 0.0, 0.486)
}

func light_note(on: bool):
	var current_material = mesh.material_override
	if current_material == null:
		current_material = StandardMaterial3D.new()
	var newMaterial = current_material.duplicate()
	if (on):
		newMaterial.albedo_color = color_map[key_index]
	else:
		newMaterial.albedo_color = Color(1.0, 1.0, 1.0)
	mesh.material_override = newMaterial

func set_state(new_state: KeyState):
	if state != new_state:
		state = new_state
		match state:
			KeyState.OFF:
				anim_player.play("off")
			KeyState.ON:
				anim_player.play("on")


func _input(event):
	if not CsoundState._keyboard_ready:
		return
		
	if event is InputEventKey and key_index in key_map:
		if event.keycode == key_map[key_index]:
			if event.pressed:
				if state == KeyState.ON:
					return
				csound.note_on(0, 67 + key_index, 90)
				set_state(KeyState.ON)
				key_pressed.emit(key_index)
			else:
				csound.note_off(0, 67 + key_index)
				set_state(KeyState.OFF)
				key_released.emit(key_index)
