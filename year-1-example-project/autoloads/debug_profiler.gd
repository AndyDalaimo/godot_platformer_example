extends Node

var _mouse_captured: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_mouse_captured = true ## Mouse captured by Player Script
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		get_tree().quit()
	if event.is_action_pressed("debug_regain_mouse_control"):
		if _mouse_captured:
			_mouse_captured = false
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			_mouse_captured = true
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
