extends Node

@export var melody = [] # for playing along
@export var notes = []
@export var tempo = 120
@export var score = 0
@export var max_combo = 0
@export var current_combo = 0

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
