extends Node3D

@export var key_index: int = 0
@export var blackKey: bool = false
@onready var anim_player = $AnimationPlayer
@onready var mesh = $MeshInstance3D

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
	if event is InputEventKey and key_index in key_map:
		if event.keycode == key_map[key_index]:
			if event.pressed:
				set_state(KeyState.ON)
			else:
				set_state(KeyState.OFF)
