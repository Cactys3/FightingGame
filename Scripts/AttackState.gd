extends CharacterState
class_name AttackState

func _init():
	super()
	normal_priority = NormalPriorities.FiveA

enum NormalPriorities {unset, FiveA, FiveB, SixA, SixB, FourA, FourB, TwoA, TwoB, ThreeA, ThreeB, OneA, OneB}
var normal_priority: NormalPriorities = NormalPriorities.unset
@export var startup_frames: int = 0
@export var active_frames: int = 0
@export var recovery_frames: int = 0
@export var block_stun: int = 0
@export var hit_stun: int = 0
@export var pushback_onhit: int = 0
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
		state_queue.force_add(character.stand.instantiate(), stand_buffer)
func enable_state(chara: Character):
	super(chara)
## Getting hit, handle punish/counter
## Handle Normal Priorities and cancels
func transition_to_stand(state: CharacterState, force: bool) -> bool:
	if animation.is_at_end(frame):
		return super(state, force)
	return false
func transition_to_normal(state: CharacterState, force: bool) -> bool:
	if cancellable && can_cancel_into_normal(state):
		return super(state, force)
	return false
func transition_to_special(state: CharacterState, force: bool) -> bool:
	return super(state, force)
func transition_to_super(state: CharacterState, force: bool) -> bool:
	return super(state, force)
func transition_to_ultimate(state: CharacterState, force: bool) -> bool:
	return super(state, force)
func transition_to_jump(state: CharacterState, force: bool) -> bool:
	return super(state, force)
func transition_to_dash(state: CharacterState, force: bool) -> bool:
	return super(state, force)

func can_cancel_into_normal(state: CharacterState) -> bool:
	match state.normal_priority:
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
