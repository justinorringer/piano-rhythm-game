extends Node2D

@onready var piano = $"../../Piano"
@onready var line_paths = $LinePaths
@onready var id_counter = 0

@export_flags("static", "dynamic") var mode = 0

var waiting_on_input_for = []

func _ready():
	if not piano:
		print("Failed to get piano")
		return
	if mode == 1:
		piano.handle_notes.connect(display_notes)
	if mode == 2:
		piano.piano_key_pressed.connect(key_pressed)


func display_notes(note):
	# get the line
	var line = find_child(note.name)
	# spawn with id
	line.spawn(id_counter)
	id_counter += 1


func spawn_note(note_name):
	# get the line
	var line = find_child(note_name)
	# spawn with id
	line.spawn(id_counter)
	id_counter += 1


func _on_play_line_area_entered(note: Area2D) -> void:
	if GameState.is_key_active(note.name):
		GameState.miss_note()
		note.queue_free()
	var id = int(note.name)
	waiting_on_input_for.push_back(id)
	

func _on_play_line_area_exited(note: Area2D) -> void:
	waiting_on_input_for.erase(int(note.name))
	note.queue_free()


func key_pressed(note):
	if waiting_on_input_for.has(note):
		GameState.hit_note()
