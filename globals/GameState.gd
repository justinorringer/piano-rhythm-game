extends Node

@export var melody = [] # for playing along
@export var notes = []
@export var tempo = 120

func store(gen_melody, gen_notes, gen_tempo):
	melody = gen_melody
	notes = gen_notes
	tempo = gen_tempo
