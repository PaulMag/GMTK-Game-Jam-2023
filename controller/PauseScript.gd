extends CanvasLayer


func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		$".."._on_button_pause_pressed()
