extends ColorRect

var key: String
var start_time: float
var duration: float
var speed: float = 300  # Pixels per second

func _ready():
	# Set note size based on duration
	size.x = duration * speed

func update_position(current_time: float):
	var elapsed_time = current_time - start_time
	position.x += 0.1
