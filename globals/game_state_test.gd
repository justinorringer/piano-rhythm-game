extends Control

func _process(delta) -> void:
	$Control/scoreCounter.text = str(GameState.score)
	$Control/comboCounter.text = "x" + str(GameState.current_combo)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_UP:
			GameState.hit_note()
		if event.keycode == KEY_DOWN:
			GameState.miss_note()
