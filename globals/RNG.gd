extends Node

# Copied from https://www.youtube.com/watch?v=gTM8vHWkD8s
@onready var instance : RandomNumberGenerator = RandomNumberGenerator.new()
func _ready():
	initialize()


func initialize():
	instance = RandomNumberGenerator.new()
	instance.randomize()


func set_from_save_data(seed: int, state: int):
	instance = RandomNumberGenerator.new()
	instance.seed = seed
	instance.state = state


func pick_random(array: Array) -> Variant:
	return array[instance.randi() % array.size()]


func shuffle(array: Array) -> void:
	if array.size() < 2:
		return
	
	for i in range(array.size() - 1, 0, -1):
		var j := instance.randi() % (i + 1)
		var tmp = array[j]
		array[j] = array[i]
		array[i] = tmp
