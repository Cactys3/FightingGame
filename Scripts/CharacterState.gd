extends Node
## Class meant to store and process the current state that a character is in. State implementations inherit this base class.
class_name CharacterState
var character: Character
var frame: int = 0
var enabled: bool = false

@export_category("Generic Properties")
@export var state_name: String = "Default"
@export var state_switching_priority: StateSwitchingPriorities = StateSwitchingPriorities.inaction
enum StateSwitchingPriorities {inaction, movement, attack, getting_hit}
@export var blocking: bool = false
@export var throwable: bool = true
@export var facing_right: bool = true
@export_category("Movement/Physics")
@export var can_transition_to_movement: bool = false
@export var crouching: bool = false
@export var airborne: bool = false
## Doesn't retain any momentum when switching into this state
@export var stop_momentum: bool = false
@export var drag: float = 0.5
@export var gravity: float = 0
@export var movespeed: float = 0
@export_category("Animation Properties")
@export var loop: bool
@export var animation: AnimSprites
@export var colliders: Array[CollisionBox]
# Variables
var state_queue: Array[CharacterState]
var active_colliders: Array[CollisionShape2D]
## Inputs
var up_pressed: bool = false
var down_pressed: bool = false
var left_pressed: bool = false
var right_pressed: bool = false
var A_pressed: bool = false
var B_pressed: bool = false
var C_pressed: bool = false
var D_pressed: bool = false
var start_pressed: bool = false
var back_pressed: bool = false

## Sets everything up based on what type of state it is, and the parameters (every state has these parameters)
func basic_setup(new_animation: AnimSprites, new_colliders: Array[CollisionBox], new_drag: float, new_facing_right: bool):
	blocking = false
	throwable = true
	crouching = false
	airborne = false
	drag = new_drag
	gravity = 0
	loop = true
	animation = new_animation
	colliders = new_colliders
	state_switching_priority = StateSwitchingPriorities.inaction
	facing_right = new_facing_right
	can_transition_to_movement = true
func movement_setup(new_movespeed: float, new_stop_momentum: bool):
	movespeed = new_movespeed
	stop_momentum = new_stop_momentum
## Current Frame Variables, setup each frame
var pressed_crouch: bool = false
var pressed_jump: bool = false

## Sets this state up as the currently active state for the given character
func enable_state(chara: Character):
	character = chara
	frame = 0
	enabled = true
## Disables this state when transitioning to another state
func disable_state():
	pass
## 60 FPS Process
func _physics_process(_delta: float) -> void:
	if !enabled:
		return
	reset_stuff()
	advance_frame()
	advance_animation()
	setup_collision()
	process_variables()
	process_inputs()
	process_collisions()
	process_movement()
	process_unique()
	check_state_queue()
## Process Methods
func reset_stuff():
	state_queue.clear()
	up_pressed = false
	down_pressed = false
	left_pressed = false
	right_pressed = false
	A_pressed = false
	B_pressed = false
	C_pressed = false
	D_pressed = false
	start_pressed = false
	back_pressed = false
func advance_frame():
	frame += 1 
## Set Animation based on framecount, loop if desired
func advance_animation():
	if animation.go_next_or_stall(character) && animation.is_at_end():
		if loop:
			animation.reset(character)
		else:
			pass ## TODO: go to next state bud
## Setup/Enable hurt/hitboxes based on framecount 
func setup_collision():
	for shape in colliders:
		## If CollisionBox should be active on this frame
		if shape.active_frames.has(frame):
			var new_collider: CollisionShape2D = CollisionShape2D.new()
			new_collider.shape = shape
			if shape.hitbox:
				character.hitbox.add_child(new_collider)
			else:
				character.hurtbox.add_child(new_collider)
			active_colliders.append(new_collider)
		else:
			for collider in active_colliders:
				## Disable if CollisionBox is enabled
				if collider.shape == shape:
					active_colliders.erase(collider)
					collider.queue_free()
## Set Variables that happen at specific times during animations/states
func process_variables():
	pass
## Go through each input and check if it's being pressed, then set boolean var values for this frame to be handled in end step
func process_inputs():
	## Grab Inputs # TODO: input buffer
	up_pressed = Input.is_action_pressed("Up")
	down_pressed = Input.is_action_pressed("Down")
	left_pressed = Input.is_action_pressed("Left")
	right_pressed = Input.is_action_pressed("Right")
	A_pressed = Input.is_action_pressed("A")
	B_pressed = Input.is_action_pressed("B")
	C_pressed = Input.is_action_pressed("C")
	D_pressed = Input.is_action_pressed("D")
	start_pressed = Input.is_action_pressed("Start")
	back_pressed = Input.is_action_pressed("Back")
	
	if can_transition_to_movement:
		transition_to_movement()
## Go through each hurtbox and check if any opponent hitboxes are inside it. Go through each hitbox and check if any opponent hurtboxes are inside it.
func process_collisions():
	pass
## Handle changing state based on variables set for this frame
func check_state_queue():
	if state_queue.is_empty():
		return
	var highest_priority_state: CharacterState = state_queue[0]
	for state in state_queue:
		if state.state_switching_priority > highest_priority_state.state_switching_priority:
			highest_priority_state = state
	character.change_state(highest_priority_state)

func transition_to_movement():
	check_forward()
	check_backward()
	check_up()
	check_down()
## Checks
func check_forward():
	## Forward
	if left_pressed && !facing_right:
		print("transition to forward_walk - left")
		state_queue.append(character.get_forward_walk())
	elif right_pressed && facing_right:
		print("transition to forward_walk - right")
		state_queue.append(character.get_forward_walk())
func check_backward():
	## Backward
	if left_pressed && facing_right:
		print("transition to backward_walk - left")
		state_queue.append(character.get_backward_walk())
	elif right_pressed && !facing_right:
		print("transition to backward_walk - right")
		state_queue.append(character.get_backward_walk())
func check_up():
	pass
func check_down():
	pass
func check_grounded():
	pass
func process_movement():
	if drag > 0 && character.velocity != Vector2.ZERO:
		var new_movement: Vector2 = character.velocity * drag
		if new_movement.abs() > Vector2(0.1, 0.1):
			character.set_movement(new_movement)
		else:
			character.velocity = Vector2.ZERO
	character.process_movement()
## Happens after all process but before state change
func process_unique():
	pass
