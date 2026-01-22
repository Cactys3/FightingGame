extends Node2D
class_name Character
## Input Constants
const UP: String = "Up"
const DOWN: String = "Down"
const LEFT: String = "Left"
const RIGHT: String = "Right"
const A: String = "A"
const B: String = "B"
const C: String = "C"
const D: String = "D"
const START: String = "Start"
const BACK: String = "Back"
@onready var anim: Sprite2D = $Sprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var hurtbox: Area2D = $Hurtbox
var current_state: CharacterState
var input_buffer: InputBuffer = InputBuffer.new()
var velocity: Vector2 = Vector2.ZERO
var facing_right: bool = true
## Basic States
@export_group("Basic States")
@export var stand: PackedScene
@export var crouch: PackedScene
@export var forward_walk: PackedScene 
@export var backward_walk: PackedScene
@export var forward_dash: PackedScene
@export var backward_dash: PackedScene
@export var jump: PackedScene
		#- jump squat
		#- airborne
		#- landing squat
	#- jump back
	#- jump forward
## Attack States

## Defense States
@export var stand_block: PackedScene
@export var crouch_block: PackedScene
@export var hitsun: PackedScene
	#- air block
	#- grounded combo (stand)
	#- grounded combo (crouch)
	#- aerial combo (juggle)

func _ready() -> void:
	change_state(stand.instantiate())
## Called when a state change is decided upon
func change_state(new_state: CharacterState):
	if current_state:
		current_state.disable_state()
		remove_child(current_state)
	current_state = new_state
	new_state.enable_state(self)
	add_child(new_state)
## Called Once Per Frame to Set Character's Sprite, pass in a SpriteFrame's sprite (texture2d)
func set_sprite(sprite: Texture2D):
	if sprite:
		anim.texture = sprite
## Called Once Per Frame to Handle Movement
func process_movement():
	position += velocity
func add_movement(added_velocity: Vector2):
	print("add: " + str(added_velocity))
	velocity += added_velocity
func set_movement(new_velocity: Vector2):
	velocity = new_velocity
## Returns a setup InputState based on InputBuffer and Input.action_pressed
func get_inputs() -> InputState:
	## Advance Frames First (maybe should do it after adding new buffers since buffers are counted on this frame too)
	input_buffer.advance_frame()
	var state: InputState = InputState.new()
	## Buffer new inputs (just pressed)
	if Input.is_action_just_pressed(UP):
		input_buffer.buffer(UP, 5)
		state.up = true
	if Input.is_action_just_pressed(DOWN):
		input_buffer.buffer(DOWN, 5)
		state.down = true
	if Input.is_action_just_pressed(LEFT):
		input_buffer.buffer(LEFT, 5)
		state.left = true
	if Input.is_action_just_pressed(RIGHT):
		input_buffer.buffer(RIGHT, 5)
		state.right = true
	if Input.is_action_just_pressed(A):
		input_buffer.buffer(A, 10)
		state.A = true
	if Input.is_action_just_pressed(B):
		input_buffer.buffer(B, 10)
		state.B = true
	if Input.is_action_just_pressed(C):
		input_buffer.buffer(C, 10)
		state.C = true
	if Input.is_action_just_pressed(D):
		input_buffer.buffer(D, 10)
		state.D = true
	if Input.is_action_just_pressed(START):
		pass
	if Input.is_action_just_pressed(BACK):
		pass
	## Check buffer and current inputs (pressed)
	if Input.is_action_pressed(UP) || input_buffer.is_buffered(UP):
		state.up = true
	if Input.is_action_pressed(DOWN) || input_buffer.is_buffered(DOWN):
		state.down = true
	if Input.is_action_pressed(LEFT) || input_buffer.is_buffered(LEFT):
		state.left = true
	if Input.is_action_pressed(RIGHT) || input_buffer.is_buffered(RIGHT):
		state.right = true
	if Input.is_action_pressed(A) || input_buffer.is_buffered(A):
		state.A = true
	if Input.is_action_pressed(B) || input_buffer.is_buffered(B):
		state.B = true
	if Input.is_action_pressed(C) || input_buffer.is_buffered(C):
		state.C = true
	if Input.is_action_pressed(D) || input_buffer.is_buffered(D):
		state.D = true
	if Input.is_action_pressed(START) || input_buffer.is_buffered(START):
		state.start = true
	if Input.is_action_pressed(BACK) || input_buffer.is_buffered(BACK):
		state.back = true
	## SOCD - Neutral Up Wins
	if state.up && state.down:
		state.down = false
	if state.left && state.right:
		state.left = false
		state.right = false
	return state

## A bool for each standard input, used for sending current InputState to a CharacterState
class InputState:
	var up: bool = false
	var down: bool = false
	var left: bool = false
	var right: bool = false
	var A: bool = false
	var B: bool = false
	var C: bool = false
	var D: bool = false
	var start: bool = false
	var back: bool = false
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
