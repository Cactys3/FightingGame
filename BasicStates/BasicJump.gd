extends CharacterState
class_name JumpState


func _init():
	state_name = "Jump"
	state_switching_priority = StateSwitchingPriorities.jump
	super()


@export_category("JumpState Specifics")
## How fast you move upward for 'jumpframes'
@export var jump_impulse: float = 8
## How fast you move forward
@export var jump_speed_x_front: float = 4
## How fast you move backward
@export var jump_speed_x_back: float = 2
## How many frames you have to cancel a jump before it goes off
@export var jump_startup_frames: int = 4
## After startup, How many frames you move upward before transitioning to 'fall' state where you can use moves
@export var jump_active_frames: int = 4
var total_frames:
	get():
		return jump_startup_frames + jump_active_frames
enum jump_types {back, neutral, front}
var jump_type = jump_types.neutral
var startup_complete: bool = false
var applied_impulse: bool = false
func enable_state(chara: Character):
	super(chara)
	character.set_movement(Vector2(character.velocity.x, 0))
	input_state = character.get_inputs()
	if input_state.left && character.facing_right || input_state.right && !character.facing_right:
		jump_type = jump_types.back
	elif input_state.left && !character.facing_right || input_state.right && character.facing_right:
		jump_type = jump_types.front
	else:
		jump_type = jump_types.neutral
	## Reset Momentum if moving in the wrong direction
	var movement_sign_offset: int = 1
	if !character.facing_right:
		movement_sign_offset = -1
	character.set_movement(Vector2.ZERO)
	match(jump_type):
		jump_types.back:
			if sign(character.velocity.x) != sign(movement_sign_offset * -jump_speed_x_back):
				character.set_movement(Vector2.ZERO)
		jump_types.neutral:
			if character.velocity.x != 0:
				character.set_movement(Vector2.ZERO)
		jump_types.front:
			if sign(character.velocity.x) != sign(movement_sign_offset * -jump_speed_x_back):
				character.set_movement(Vector2.ZERO)
func advance_frame():
	super()
	## If past startup, we are committed to the jump and can't cancel
	if frame >= jump_startup_frames && !startup_complete:
		startup_complete = true
		disable_all_transitionability()
		falling_transitionable = true
		getting_hit_transitionable = true
func check_fall():
	## If total frames, we are done jumping and can force a fall
	if frame >= total_frames:
		## Force Add
		state_queue.force_add(character.fall.instantiate(), falling_buffer)
func check_jump():
	pass

## Overwrite with jump movement
func process_movement():
	if startup_complete && !applied_impulse:
		var movement_sign_offset: int = 1
		if !character.facing_right:
			movement_sign_offset = -1
		var new_velocity: Vector2 = Vector2(0, -jump_impulse)
		match(jump_type):
			jump_types.back:
				new_velocity = Vector2(movement_sign_offset * -jump_speed_x_back, new_velocity.y)
			jump_types.neutral:
				new_velocity = Vector2(0, new_velocity.y)
			jump_types.front:
				new_velocity = Vector2(movement_sign_offset * jump_speed_x_front, new_velocity.y)
		applied_impulse = true
		character.add_movement(new_velocity)
	character.process_movement()

func transition_to_state(state: CharacterState, force_unless_hit: bool) -> bool:
	return super(state, force_unless_hit)
