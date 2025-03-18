extends Node2D
var note_node = load("res://components/staff/note.tscn")

const RATIO_NEEDED = 0.9279
@onready var path_follow : PathFollow2D = $LinePath2D/PathFollow2D
@onready var spawn_point : Marker2D = $SpawnPoint
@onready var foster_parent = $TempHome
@export var speed = 100
@export var note_name = "C"
var active = false

func _ready():
	speed = 60 / GameState.tempo

func _physics_process(delta: float):
	if not active:
		return
	
	#i need to go 
	# speed is bpm
	# delta is time per frame
	path_follow.progress_ratio += speed * delta
	
	if path_follow.progress_ratio == 1.0:
		for c in path_follow.get_children():
			# temporarily store them outside of the linepath
			c.reparent(foster_parent)
		path_follow.progress_ratio = 0.0
		for c in foster_parent.get_children():
			c.reparent(path_follow)


func spawn(id):
	var note_instance = note_node.instantiate()
	path_follow.add_child(note_instance)
	note_instance.global_transform = spawn_point.global_transform
	note_instance.name = str(id)
	note_instance.change_color(name)
	active = true

func despawn(id):
	path_follow.find_child(id).queue_free()
	if path_follow.get_children().size() == 0:
		active = false
		path_follow.progress_ratio = 0.0
