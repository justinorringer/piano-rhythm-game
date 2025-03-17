extends Node2D

@onready var generator_test = $GeneratorTest

func _ready() -> void:
	generator_test.generated_test.connect(play_test)

func play_test():
	var notes = generator_test.notes
	var tempo = generator_test.tempo
	
	Player.play(notes, tempo)
