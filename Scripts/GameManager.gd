extends Node2D
class_name GameManager
static var instance: GameManager = null
static var instance_ready: bool = false

@export var InputHistory_P1: InputHistory
@export var InputHistory_P2: InputHistory
func _ready() -> void:
	if instance && instance != self:
		printerr("can't be two game manager")
		get_tree().quit()
	instance = self
	instance_ready = true
func change_input_history(p1: bool, state: String, time: String, index: int):
	var text: String = state + " - " + time
	if p1:
		if InputHistory_P1:
			InputHistory_P1.change(text, index)
	else:
		if InputHistory_P2:
			InputHistory_P2.change(text, index)
func add_input_history(p1: bool, state: String, time: String):
	var text: String = state + " - " + time
	if p1:
		if InputHistory_P1:
			InputHistory_P1.add(text)
	else:
		if InputHistory_P2:
			InputHistory_P2.add(text)
