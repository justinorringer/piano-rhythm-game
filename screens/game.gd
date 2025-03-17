extends Node2D

func _ready() -> void:
	Player.play(GameState.notes, GameState.tempo)

func _on_button_pressed() -> void:
	SceneSwitch.switch_scene("res://screens/score.tscn")
