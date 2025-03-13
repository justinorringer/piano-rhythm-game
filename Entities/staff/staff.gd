extends Control

@onready var piano = $"../Piano"
@onready var text = $'RichTextLabel'

func _ready():
	piano.handle_notes.connect(display_notes)


func display_notes(note):
	# TODO temporary obv
	text.append_text(note.name + " ")
