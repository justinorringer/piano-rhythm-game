extends Node2D


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
		"name": "Eb",
		"length": "eighth",
	},
	{
		"name": "D",
		"length": "eighth",
	},
]
func _ready():
	print("mod of 6 by -1", -6 % 2)
	await get_tree().create_timer(1.0).timeout
	var prog = Generator.generate_chord_progression(ode_to_test_notes)
	print("Generated progression", prog)
	var relations = Generator.pick_chord_relation(prog)
	print("Relations chosen", relations)
	print("Generation results", Generator.generate(ode_to_test_notes, 120))
