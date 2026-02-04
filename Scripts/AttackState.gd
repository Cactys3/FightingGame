extends CharacterState
class_name AttackState
func _init():
	super()
enum AirNormalPriorities {unset, A, B}
enum NormalPriorities {unset, FiveA, FiveB, SixA, SixB, FourA, FourB, TwoA, TwoB, ThreeA, ThreeB, OneA, OneB}
var normal_priority: NormalPriorities = NormalPriorities.unset
## Hit Variables
@export var combo_scaling: float = 0
@export var damage_onhit: float = 0
## Chip Damage
@export var damage_onblock: float = 0
## X-Direction pushback
@export var pushback_onhit: float = 0
## X-Direction pushback
@export var pushback_onblock: float = 0
## Does this keep them grounded onhit or launch
@export var launch_onhit: bool
## The Y Value applied to enemy when they are grounded
@export var launch_height: float = 0
@export var launch_onhit_counter_hit: bool
@export var launch_height_counter_hit: float = 0
## The Y Value applied to enemy when they are airborne or already being juggled
@export var juggle_height: float = 0
## Can't be blocked crouching
@export var overhead: bool = false
## Can't be blocked standing
@export var low: bool = false
## Just for reference, incase some moves are jump-in immune
@export var jump_in: bool = false
@export var blockstun: int = 0
@export var hitstun: int = 0
@export var hitstun_counter_hit: int = 0
@export var hitstun_punish_hit: int = 0
## Frames
@export var startup_frames: int = 0
@export var active_frames: int = 0
@export var recovery_frames: int = 0
@export_group("Cancels")
@export var fiveA_transitionable: bool = false
@export var fiveB_transitionable: bool = false
@export var sixA_transitionable: bool = false
@export var sixB_transitionable: bool = false
@export var fourA_transitionable: bool = false
@export var fourB_transitionable: bool = false
@export var twoA_transitionable: bool = false
@export var twoB_transitionable: bool = false
@export var threeA_transitionable: bool = false
@export var threeB_transitionable: bool = false
@export var oneA_transitionable: bool = false
@export var oneB_transitionable: bool = false
## Current Frame Variables, setup each frame
var currently_startup: bool = false
var currently_active: bool = false
var currently_recovery: bool = false
var cancellable: bool = false
var kara_cancellable: bool = false
func advance_frame():
	super()
	if frame >= startup_frames + active_frames:
		currently_recovery = true
		cancellable = true
	elif frame >= startup_frames:
		currently_active = true
		cancellable = false
	else:
		currently_startup = true
		cancellable = false
## Check transitioning after animation is done
func process_unique():
	if frame >= startup_frames + active_frames + recovery_frames:#if animation.is_at_end(frame):
		state_queue.force_add(character.stand.instantiate(), stand_buffer, [])
func enable_state(chara: Character, args: Array):
	super(chara, args)
## Getting hit, handle punish/counter
## Handle Normal Priorities and cancels
func transition_to_stand(state: CharacterState, force: bool, args: Array) -> bool:
	if animation.is_at_end(frame):
		return super(state, force, args)
	return false
func transition_to_normal(state: CharacterState, force: bool, args: Array) -> bool:
	if cancellable && can_cancel_into_normal(state):
		return super(state, force, args)
	return false
func transition_to_special(state: CharacterState, force: bool, args: Array) -> bool:
	return super(state, force, args)
func transition_to_super(state: CharacterState, force: bool, args: Array) -> bool:
	return super(state, force, args)
func transition_to_ultimate(state: CharacterState, force: bool, args: Array) -> bool:
	return super(state, force, args)
func transition_to_jump(state: CharacterState, force: bool, args: Array) -> bool:
	return super(state, force, args)
func transition_to_dash(state: CharacterState, force: bool, args: Array) -> bool:
	return super(state, force, args)
## can't block while attacking
func is_blocking() -> bool:
	return false
func can_cancel_into_normal(state: CharacterState) -> bool:
	match normal_priority:
		NormalPriorities.unset:
			return false
		NormalPriorities.FiveA:
			return fiveA_transitionable
		NormalPriorities.FiveB:
			return fiveB_transitionable
		NormalPriorities.SixA:
			return sixA_transitionable
		NormalPriorities.SixB:
			return sixB_transitionable
		NormalPriorities.FourA:
			return fourA_transitionable
		NormalPriorities.FourB:
			return fourB_transitionable
		NormalPriorities.TwoA:
			return twoA_transitionable
		NormalPriorities.TwoB:
			return twoB_transitionable
		NormalPriorities.ThreeA:
			return threeA_transitionable
		NormalPriorities.ThreeB:
			return threeB_transitionable
		NormalPriorities.OneA:
			return oneA_transitionable
		NormalPriorities.OneB:
			return oneB_transitionable
	return false


func get_collision_element() -> CollisionQueueElement:
	return CollisionQueueElement.new(self, combo_scaling, damage_onhit, damage_onblock, pushback_onhit, pushback_onblock, launch_onhit, launch_height, juggle_height, overhead, low, jump_in, blockstun, hitstun)
func get_collision_element_counter_hit() -> CollisionQueueElement:
	return CollisionQueueElement.new(self, combo_scaling, damage_onhit, damage_onblock, pushback_onhit, pushback_onblock, launch_onhit_counter_hit, launch_height_counter_hit, juggle_height, overhead, low, jump_in, blockstun, hitstun_counter_hit)
func get_collision_element_punish_hit() -> CollisionQueueElement:
	return CollisionQueueElement.new(self, combo_scaling, damage_onhit, damage_onblock, pushback_onhit, pushback_onblock, launch_onhit, launch_height, juggle_height, overhead, low, jump_in, blockstun, hitstun_punish_hit)
