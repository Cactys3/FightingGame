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
		setup_state_and_buffer(state, p1_input_buffer, P1_UP, P1_DOWN, P1_LEFT, P1_RIGHT, P1_A, P1_B, P1_C, P1_START, P1_BACK)
	else:
		setup_state_and_buffer(state, p2_input_buffer, P2_UP, P2_DOWN, P2_LEFT, P2_RIGHT, P2_A, P2_B, P2_C, P2_START, P2_BACK)
	return state

func setup_state_and_buffer(state: Character.InputState, buffer: InputBuffer, UP, DOWN, LEFT, RIGHT, A, B, C, START, BACK):
	## Inputs
	if Input.is_action_just_pressed(UP):
		state.up = true
		buffer.buffer(UP, movement_buffer)
	if Input.is_action_just_pressed(DOWN):
		state.down = true
		buffer.buffer(DOWN, movement_buffer)
	if Input.is_action_just_pressed(LEFT):
		state.left = true
		buffer.buffer(LEFT, movement_buffer)
	if Input.is_action_just_pressed(RIGHT):
		state.right = true
		buffer.buffer(RIGHT, movement_buffer)
	if Input.is_action_just_pressed(A):
		state.A = true
		buffer.buffer(A, attack_buffer)
	if Input.is_action_just_pressed(B):
		state.B = true
		buffer.buffer(B, attack_buffer)
	if Input.is_action_just_pressed(C):
		state.C = true
		buffer.buffer(C, attack_buffer)
	if Input.is_action_just_pressed(START):
		state.start = true
		#buffer.buffer(P1_START, 0)
	if Input.is_action_just_pressed(BACK):
		state.back = true
		#buffer.buffer(P1_BACK, 0)
	## Buffers
	if Input.is_action_pressed(UP) || buffer.is_buffered(UP):
		state.up = true
	if Input.is_action_pressed(DOWN) || buffer.is_buffered(DOWN):
		state.down = true
	if Input.is_action_pressed(LEFT) || buffer.is_buffered(LEFT):
		state.left = true
	if Input.is_action_pressed(RIGHT) || buffer.is_buffered(RIGHT):
		state.right = true
	if buffer.is_buffered(A):
		state.A = true
	if buffer.is_buffered(B):
		state.B = true
	if buffer.is_buffered(C):
		state.C = true
	if buffer.is_buffered(START):
		state.start = true
	if buffer.is_buffered(BACK):
		state.back = true
	## SOCD - Neutral Up Wins
	if state.up && state.down:
		state.down = false
	## If only buffering Left but currently pressing Right, Right should win right?
	if state.left && state.right:
		if (Input.is_action_just_pressed(LEFT) && Input.is_action_just_pressed(RIGHT)) || (!Input.is_action_just_pressed(LEFT) && !Input.is_action_just_pressed(RIGHT)):
			state.left = false
			state.right = false
		else:
			if Input.is_action_just_pressed(LEFT):
				state.right = false
			else:
				state.left = false

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
