extends Node

@export var melody = [] # for playing along
@export var notes = []
@export var tempo = 120
@export var score = 0
@export var max_combo = 0
@export var current_combo = 0

@export var keys_active = []
const KEY_MAP = {
	1: KEY_A,  2: KEY_W,  3: KEY_S,  4: KEY_E,  
	5: KEY_D,  6: KEY_F,  7: KEY_T,  8: KEY_G,  
	9: KEY_Y, 10: KEY_H, 11: KEY_U, 12: KEY_J
}

func store(gen_melody, gen_notes, gen_tempo):
	melody = gen_melody
	notes = gen_notes
	tempo = gen_tempo

func hit_note():
	score += current_combo
	current_combo += 1
	if (max_combo < current_combo):
		max_combo = current_combo

func miss_note():
	current_combo = 0

func append_keys_active(well):
	keys_active.push_back(well)

func remove_keys_active(well):
	keys_active.erase(well)

func is_key_active(well):
	return keys_active.has(well)
