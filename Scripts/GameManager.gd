extends Node2D
class_name GameManager
static var instance: GameManager = null
static var instance_ready: bool = false
## Buffer Frame Counts
const movement_buffer: int = 4
const attack_buffer: int = 5
## P1 Input Constants
const P1_UP: String = "P1_Up"
const P1_DOWN: String = "P1_Down"
const P1_LEFT: String = "P1_Left"
const P1_RIGHT: String = "P1_Right"
const P1_A: String = "P1_A"
const P1_B: String = "P1_B"
const P1_C: String = "P1_C"
const P1_D: String = "P1_D"
const P1_START: String = "P1_Start"
const P1_BACK: String = "P1_Back"
## P2 Input Constants
const P2_UP: String = "P2_Up"
const P2_DOWN: String = "P2_Down"
const P2_LEFT: String = "P2_Left"
const P2_RIGHT: String = "P2_Right"
const P2_A: String = "P2_A"
const P2_B: String = "P2_B"
const P2_C: String = "P2_C"
const P2_D: String = "P2_D"
const P2_START: String = "P2_Start"
const P2_BACK: String = "P2_Back"

var p1_input_buffer: InputBuffer = InputBuffer.new()
var p2_input_buffer: InputBuffer = InputBuffer.new()
@export var P1: Character
@export var P2: Character

@export var InputHistory_P1: InputHistory
@export var InputHistory_P2: InputHistory
func _ready() -> void:
	if instance && instance != self:
		printerr("can't be two game manager")
		get_tree().quit()
	instance = self
	instance_ready = true

func _physics_process(delta: float) -> void:
	setup_characters()
	P1.process_frame()
	P2.process_frame()

## Sets character up for process
func setup_characters():
	# set p1/p2
	P1.p1 = true
	P2.p1 = false
	p1_input_buffer.advance_frame()
	p2_input_buffer.advance_frame()
	if P1.global_position.x > P2.global_position.x:
		P1.facing_right = false
		P2.facing_right = true
	else:
		P1.facing_right = true
		P2.facing_right = false
func get_inputs(p1: bool) -> Character.InputState:
	var state: Character.InputState = Character.InputState.new()
	if p1:
		## Inputs
		if Input.is_action_just_pressed(P1_UP):
			state.up = true
			p1_input_buffer.buffer(P1_UP, movement_buffer)
		if Input.is_action_just_pressed(P1_DOWN):
			state.down = true
			p1_input_buffer.buffer(P1_DOWN, movement_buffer)
		if Input.is_action_just_pressed(P1_LEFT):
			state.left = true
			p1_input_buffer.buffer(P1_LEFT, movement_buffer)
		if Input.is_action_just_pressed(P1_RIGHT):
			state.right = true
			p1_input_buffer.buffer(P1_RIGHT, movement_buffer)
		if Input.is_action_just_pressed(P1_A):
			state.A = true
			p1_input_buffer.buffer(P1_A, attack_buffer)
		if Input.is_action_just_pressed(P1_B):
			state.B = true
			p1_input_buffer.buffer(P1_B, attack_buffer)
		if Input.is_action_just_pressed(P1_C):
			state.C = true
			p1_input_buffer.buffer(P1_C, attack_buffer)
		if Input.is_action_just_pressed(P1_START):
			state.start = true
			#p1_input_buffer.buffer(P1_START, 0)
		if Input.is_action_just_pressed(P1_BACK):
			state.back = true
			#p1_input_buffer.buffer(P1_BACK, 0)
		## Buffers
		if Input.is_action_pressed(P1_UP) || p1_input_buffer.is_buffered(P1_UP):
			state.up = true
		if Input.is_action_pressed(P1_DOWN) || p1_input_buffer.is_buffered(P1_DOWN):
			state.down = true
		if Input.is_action_pressed(P1_LEFT) || p1_input_buffer.is_buffered(P1_LEFT):
			state.left = true
		if Input.is_action_pressed(P1_RIGHT) || p1_input_buffer.is_buffered(P1_RIGHT):
			state.right = true
		if p1_input_buffer.is_buffered(P1_A):
			state.A = true
		if p1_input_buffer.is_buffered(P1_B):
			state.B = true
		if p1_input_buffer.is_buffered(P1_C):
			state.C = true
		if p1_input_buffer.is_buffered(P1_START):
			state.start = true
		if p1_input_buffer.is_buffered(P1_BACK):
			state.back = true
	else:
		## Inputs
		if Input.is_action_just_pressed(P2_UP):
			state.up = true
			p2_input_buffer.buffer(P2_UP, movement_buffer)
		if Input.is_action_just_pressed(P2_DOWN):
			state.down = true
			p2_input_buffer.buffer(P2_DOWN, movement_buffer)
		if Input.is_action_just_pressed(P2_LEFT):
			state.left = true
			p2_input_buffer.buffer(P2_LEFT, movement_buffer)
		if Input.is_action_just_pressed(P2_RIGHT):
			state.right = true
			p2_input_buffer.buffer(P2_RIGHT, movement_buffer)
		if Input.is_action_just_pressed(P2_A):
			state.A = true
			p2_input_buffer.buffer(P2_A, attack_buffer)
		if Input.is_action_just_pressed(P2_B):
			state.B = true
			p2_input_buffer.buffer(P2_B, attack_buffer)
		if Input.is_action_just_pressed(P2_C):
			state.C = true
			p2_input_buffer.buffer(P2_C, attack_buffer)
		if Input.is_action_just_pressed(P2_START):
			state.start = true
			#p2_input_buffer.buffer(P2_START, movement_buffer)
		if Input.is_action_just_pressed(P2_BACK):
			state.back = true
			#p2_input_buffer.buffer(P2_BACK, movement_buffer)
		## Buffers
		if Input.is_action_pressed(P2_UP) || p2_input_buffer.is_buffered(P2_UP):
			state.up = true
		if Input.is_action_pressed(P2_DOWN) || p2_input_buffer.is_buffered(P2_DOWN):
			state.down = true
		if Input.is_action_pressed(P2_LEFT) || p2_input_buffer.is_buffered(P2_LEFT):
			state.left = true
		if Input.is_action_pressed(P2_RIGHT) || p2_input_buffer.is_buffered(P2_RIGHT):
			state.right = true
		if Input.is_action_pressed(P2_A) || p2_input_buffer.is_buffered(P2_A):
			state.A = true
		if Input.is_action_pressed(P2_B) || p2_input_buffer.is_buffered(P2_B):
			state.B = true
		if Input.is_action_pressed(P2_C) || p2_input_buffer.is_buffered(P2_C):
			state.C = true
		if Input.is_action_pressed(P2_START) || p2_input_buffer.is_buffered(P2_START):
			state.start = true
		if Input.is_action_pressed(P2_BACK) || p2_input_buffer.is_buffered(P2_BACK):
			state.back = true
	## SOCD - Neutral Up Wins
	if state.up && state.down:
		state.down = false
	## If only buffering Left but currently pressing Right, Right should win right?
	var left: String
	var right: String
	if p1:
		left = P1_LEFT
		right = P1_RIGHT
	else:
		left = P2_LEFT
		right = P2_RIGHT
	if state.left && state.right:
		if (Input.is_action_just_pressed(left) && Input.is_action_just_pressed(right)) || (!Input.is_action_just_pressed(left) && !Input.is_action_just_pressed(right)):
			state.left = false
			state.right = false
		else:
			if Input.is_action_just_pressed(left):
				state.right = false
			else:
				state.left = false
	return state


## UI
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



## Used to store inputs for a certian number of frames
class InputBuffer:
	var array: Array[InputElement]
	## Advances all Buffered inputs to the next frame
	func advance_frame():
		for input: InputElement in array:
			input.reduce_buffer_or_delete(array)
	## Adds an input buffer for the next buffer_frames frames
	func buffer(new_name, buffer_frames):
		array.append(InputElement.new(new_name, buffer_frames))
	## Checks if an input has been buffered (as active)
	func is_buffered(input_name) -> bool:
		for element in array:
			if element.input_name == input_name:
				return true
		return false
	class InputElement:
		func _init(new_name, buffer_frames):
			input_name = new_name
			buffer_frames_left = buffer_frames
		var input_name: String
		var buffer_frames_left: int = 10
		func reduce_buffer_or_delete(buffer: Array):
			buffer_frames_left -= 1
			if buffer_frames_left <= 0 && buffer.has(self):
				buffer.erase(self)
				## TODO: does this need to free? or does reference counting handle this?
