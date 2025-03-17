extends Node2D

@export var notes = []
@export var tempo = 100

signal generated_test()

@onready var ode_to_test_notes = [
	{
		"name": "D",
		"length": "quarter",
	},
	{
		"name": "D",
		"length": "quarter",
	},
	{
		"name": "Eb",
		"length": "quarter",
	},
	{
		"name": "F",
		"length": "quarter",
	},
	{
		"name": "F",
		"length": "quarter",
	},
	{
		"name": "Eb",
		"length": "eighth",
	},
	{
		"name": "D",
		"length": "eighth",
	},
]
func _ready():
	await get_tree().create_timer(1.0).timeout
	var prog = Generator.generate_chord_progression(ode_to_test_notes)
	print("Generated progression", prog)
	var relations = Generator.pick_chord_relation(prog)
	
	var with_counts = Generator.assign_counts(ode_to_test_notes)
	print("With counts", with_counts)
	print("Relations chosen", relations)
	Generator.generate(ode_to_test_notes, tempo)
	generated_test.emit()
