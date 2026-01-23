extends CharacterState
class_name JumpState
@export_category("JumpState Specifics")
## How fast you move upward for 'jumpframes'
@export var jump_speed: float = 10
## How many frames you have to cancel a jump before it goes off
@export var jump_startup_frames: int = 4
## After startup, How many frames you move upward before transitioning to 'fall' state where you can use moves
@export var jump_complete_frames: int = 6

enum jump_types {back, neutral, forward}
var jump_type = jump_types.neutral
var startup_complete: bool = false

func enable_state(chara: Character):
	super(chara)
	character.set_movement(Vector2(character.velocity.x, 0))

func advance_frame():
	super()
	if frame == jump_startup_frames:
		startup_complete = true
		dash_transitionable = false
		normal_transitionable = false
		disable_all_transitionability()
		falling_transitionable = true
		getting_hit_transitionable = true
	
	if frame == jump_complete_frames:
		## Force change_state?
		#character.change_state(character.fall.instantiate())
		print("fall")
		state_queue.append(character.fall.instantiate())

func check_jump():
	pass

## Overwrite with jump movement
func process_movement():
	var movement_sign_offset: int = 1
	if !character.facing_right:
		movement_sign_offset = -1
	var new_velocity: Vector2 = Vector2(0, -jump_speed)
	match(jump_type):
		jump_types.back:
			pass
		jump_types.neutral:
			pass
		jump_types.forward:
			pass
	character.add_movement(new_velocity)
	character.process_movement()
