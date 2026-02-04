extends Node
## Class meant to store and process the current state that a character is in. State implementations inherit this base class.
class_name CharacterState
var character: Character
var frame: int = 0
var enabled: bool = false
var state_queue: StateQueue = StateQueue.new()
var input_state: Character.InputState = null
var collision_queue: Array[CollisionQueueElement] = []
@export_category("Generic Properties")
var state_name: String = "unset"
var state_switching_priority: StateSwitchingPriorities = StateSwitchingPriorities.unset
enum StateSwitchingPriorities {unset, crouch, stand, movement, jump, dash, normal, grab, special, parry, _super, ultimate, falling, air_dash, air_normal, air_grab, air_special, air_super, air_ultimate, getting_hit}
@export var hitbox_parent: Area2D
@export var hurtbox_parent: Area2D
@export var can_block: bool = false
@export var throwable: bool = true
@export var collider_boxes: Array[CollisionBox]
@export_category("Transition Properties")
@export var stand_transitionable: bool = false
@export var crouch_transitionable: bool = false
@export var movement_transitionable: bool = false
@export var jump_transitionable: bool = false
@export var dash_transitionable: bool = false
@export var normal_transitionable: bool = false
@export var grab_transitionable: bool = false
@export var special_transitionable: bool = false
@export var parry_transitionable: bool = false
@export var super_transitionable: bool = false
@export var ultimate_transitionable: bool = false
@export var falling_transitionable: bool = false
@export var air_dash_transitionable: bool = false
@export var air_normal_transitionable: bool = false
@export var air_grab_transitionable: bool = false
@export var air_special_transitionable: bool = false
@export var air_super_transitionable: bool = false
@export var air_ultimate_transitionable: bool = false
@export var getting_hit_transitionable: bool = true
@export_category("Movement/Physics")
@export var crouching: bool = false
@export var airborne: bool = false
@export var movespeed_sign_negative: bool = false
## Doesn't retain any momentum when switching into this state
@export var stop_momentum: bool = false
@export var drag_x: float = 0.1
@export var drag_y: float = 0
@export var gravity: float = 0
@export var max_velocity_up: float = 10
@export var max_velocity_down: float = 8
@export var max_velocity_front: float = 8
@export var max_velocity_back: float = 8
@export var movespeed: float = 0
@export_category("Animation Properties")
## Requires 'stand_transitionable = true'
@export var stand_on_anim_done: bool = false
## Requires 'crouch_transitionable = true'
@export var crouch_on_anim_done: bool = false
@export var loop: bool
@export var next_state_on_animation_end: PackedScene
@export var animation: AnimSprites
@export var colliders: Array[CollisionBox]
## Current Frame Variables, setup each frame
var pressed_crouch: bool = false
var pressed_jump: bool = false
## Debug Variables
var frames_spent_on_state: int = 0

## State Buffers
const unset_buffer: int = 0
const crouch_buffer: int = 0
const stand_buffer: int = 0
const movement_buffer: int = 0
const jump_buffer: int = 0
const dash_buffer: int = 0
const normal_buffer: int = 6
const grab_buffer: int = 0
const special_buffer: int = 4
const parry_buffer: int = 0
const _super_buffer: int = 4
const ultimate_buffer: int = 4
const falling_buffer: int = 0
const air_dash_buffer: int = 0
const air_normal_buffer: int = 4
const air_grab_buffer: int = 0
const air_special_buffer: int = 4
const air_super_buffer: int = 4
const air_ultimate_buffer: int = 4
const getting_hit_buffer: int = 0

func _init():
	pass
## Sets this state up as the currently active state for the given character
func enable_state(chara: Character, args: Array):
	character = chara
	frame = 0
	enabled = true
	if stop_momentum:
		character.set_movement(Vector2.ZERO)
	setup_collision()
## Disables this state when transitioning to another state
func disable_state():
	GameManager.instance.add_input_history(character.p1, state_name, str(frames_spent_on_state))# + "." + StateSwitchingPriorities.keys()[self.state_switching_priority])
## 60 FPS Process
func process_frame() -> void:
	if !enabled:
		return
	advance_frame()
	advance_animation()
	setup_collision()
	process_variables()
	grab_inputs()
	process_inputs()
	process_collisions()
	process_movement()
	process_unique()
	check_state_queue()
## Process Methods
func advance_frame():
	frame += 1 
	state_queue.advance_frame()
	frames_spent_on_state += 1
	GameManager.instance.change_input_history(character.p1, state_name, str(frames_spent_on_state), 0)
## Set Animation based on framecount, loop if desired
func advance_animation():
	animation.display_frame(frame, loop, character)
	if !loop && animation.is_at_end(frame):
		if next_state_on_animation_end:
			state_queue.force_add(character.next_state_on_animation_end.instantiate(), stand_buffer, [])
		elif stand_on_anim_done:
			state_queue.force_add(character.stand.instantiate(), stand_buffer, [])
		elif crouch_on_anim_done:
			state_queue.force_add(character.crouch.instantiate(), crouch_buffer, [])
func disable_collisions():
	if hurtbox_parent:
		for box: CollisionBox in hurtbox_parent.get_children():
			box.disable(frame)
	if hitbox_parent:
		for box: CollisionBox in hitbox_parent.get_children():
			box.disable(frame)
## Setup/Enable hurt/hitboxes based on framecount 
func setup_collision():
	## If CollisionBox should be active on this frame
	if hurtbox_parent:
		for box: CollisionBox in hurtbox_parent.get_children():
			box.p1 = character.p1
			if (box.active_frames.has(frame) || box.always_active) && !box.inactive_frames.has(frame):
				box.enable(frame)
				if box.print_debug:
					print("Hitbox for " + state_name + " Active on: " + str(frame))
			else:
				box.disable(frame)
				if box.print_debug:
					print("Hitbox for " + state_name + " Inactive on: " + str(frame))
	if hitbox_parent:
		for box: CollisionBox in hitbox_parent.get_children():
			box.p1 = character.p1
			if (box.active_frames.has(frame) || box.always_active) && !box.inactive_frames.has(frame):
				box.enable(frame)
				if box.print_debug:
					print("Hitbox for " + state_name + " Active on: " + str(frame))
			else:
				box.disable(frame)
				if box.print_debug:
					print("Hitbox for " + state_name + " Inactive on: " + str(frame))
				## Disable if CollisionBox is enabled
## Set Variables that happen at specific times during animations/states
func process_variables():
	pass
## Go through each input and check if it's being pressed, then set boolean var values for this frame to be handled in end step
func grab_inputs():
	input_state = character.get_inputs()
func process_inputs():
	check_fall()
	check_forward_walk()
	check_backward_walk()
	check_jump()
	check_crouch()
	check_a()
	check_b()
	check_c()
## Go through each hurtbox and check if any opponent hitboxes are inside it. Go through each hitbox and check if any opponent hurtboxes are inside it.
func process_collisions():
	collision_queue.clear()
	## Collect Collisions
	if hurtbox_parent:
		for area in hurtbox_parent.get_overlapping_areas():
			for box in area.get_children():
				if box is CollisionBox && box.active && box.is_hitbox && !is_our_box(box):
					## Queue Collision
					print("Queue Collision: " + str(frame))
					var state: AttackState = box.state
					collision_queue.append(state.get_collision_element())
	## Handle Collected Collision
	for element in collision_queue:
		if is_blocking() && (!element.overhead || element.overhead && is_standing()) && (!element.low || element.low && is_crouching()):
			if is_crouching():
				state_queue.force_add(character.crouch_blockstun.instantiate(), 0, [element])
			else:
				state_queue.force_add(character.stand_blockstun.instantiate(), 0, [element])
		else:
			if is_crouching():
				state_queue.force_add(character.crouch_hitsun.instantiate(), 0, [element])
			else:
				state_queue.force_add(character.stand_hitsun.instantiate(), 0, [element])
## Handle changing state based on variables set for this frame
func check_state_queue():
	if state_queue.is_empty():
		return
	## Sort by highest priority
	state_queue.queue.sort_custom(func(a, b): return a.state_switching_priority > b.state_switching_priority)
	## Try by highest priority (priority should make block/hitstun first always)
	for state in state_queue.queue:
		if transition_to_state(state.state, state.force_state_unless_hit, state.args):
			state_queue.remove(state)
			pass#print("Sucess: " + state_name + "." + StateSwitchingPriorities.keys()[self.state_switching_priority] + " --> " + state.state_name + "." + StateSwitchingPriorities.keys()[state.state_switching_priority])
		else:
			pass#print("Fail: " + state_name + "." + StateSwitchingPriorities.keys()[self.state_switching_priority] + " --> " + state.state_name + "." + StateSwitchingPriorities.keys()[state.state_switching_priority])
	## TODO: save state change buffers on change state and send to next state? probably not need unless i think of a reason it is
## Checks
func check_a():
	if input_state.A:
		## Check Command Normals
		if is_backward_input() && character.four_A != null:
			## Backwards
			state_queue.add(character.four_A.instantiate(), normal_buffer, [])
		## Forward
		elif input_state.down && is_forward_input() && character.four_A != null:
			## Down-Forward
			state_queue.add(character.four_A.instantiate(), normal_buffer, [])
		elif is_forward_input() && character.six_A != null:
			## Forward
			state_queue.add(character.six_A.instantiate(), normal_buffer, [])
		elif character.five_A != null:
			## Neutral
			state_queue.add(character.five_A.instantiate(), normal_buffer, [])
func check_b():
	if input_state.B:
		## Check Command Normals
		if is_backward_input() && character.four_B != null:
			## Backwards
			state_queue.add(character.four_B.instantiate(), normal_buffer, [])
		## Forward
		elif input_state.down && is_forward_input() && character.four_B != null:
			## Down-Forward
			state_queue.add(character.four_B.instantiate(), normal_buffer, [])
		elif is_forward_input() && character.six_B != null:
			## Forward
			state_queue.add(character.six_B.instantiate(), normal_buffer, [])
		elif character.five_B != null:
			## Neutral
			state_queue.add(character.five_B.instantiate(), normal_buffer, [])
func check_c():
	if input_state.B:
		## Check Command Normals
		if is_backward_input() && character.four_C != null:
			## Backwards
			state_queue.add(character.four_C.instantiate(), normal_buffer, [])
		## Forward
		elif input_state.down && is_forward_input() && character.four_C != null:
			## Down-Forward
			state_queue.add(character.four_C.instantiate(), normal_buffer, [])
		elif is_forward_input() && character.six_C != null:
			## Forward
			state_queue.add(character.six_C.instantiate(), normal_buffer, [])
		elif character.five_C != null:
			## Neutral
			state_queue.add(character.five_C.instantiate(), normal_buffer, [])
func check_d():
	if input_state.D:
		## Check Command Normals
		if is_backward_input() && character.four_D != null:
			## Backwards
			state_queue.add(character.four_D.instantiate(), normal_buffer, [])
		## Forward
		elif input_state.down && is_forward_input() && character.four_D != null:
			## Down-Forward
			state_queue.add(character.four_D.instantiate(), normal_buffer, [])
		elif is_forward_input() && character.six_D != null:
			## Forward
			state_queue.add(character.six_D.instantiate(), normal_buffer, [])
		elif character.five_D != null:
			## Neutral
			state_queue.add(character.five_D.instantiate(), normal_buffer, [])
func check_forward_walk():
	## Forward
	if is_forward_input():
		state_queue.add(character.forward_walk.instantiate(), movement_buffer, [])
func check_backward_walk():
	## Backward
	if is_backward_input():
		state_queue.add(character.backward_walk.instantiate(), movement_buffer, [])
func check_jump():
	if input_state.up:
		state_queue.add(character.jump.instantiate(), jump_buffer, [])
func check_crouch():
	if input_state.down:
		state_queue.add(character.crouch.instantiate(), crouch_buffer, [])
func check_fall():
	if !character.get_grounded():
		state_queue.add(character.fall.instantiate(), falling_buffer, [])
func process_movement():
	var movement_sign_offset: int = 1
	if !is_facing_right():
		movement_sign_offset = -1
	if movespeed_sign_negative:
		movement_sign_offset *= -1
	## X-Axis
	var should_drag_x = drag_x != 0
	if movespeed != 0:
		## If already moving in correct direction and moving faster than movespeed, don't overwrite speed, just continue
		if sign(character.velocity.x) == sign(movespeed * movement_sign_offset) && abs(character.velocity.length()) > abs(movespeed * movement_sign_offset):
			pass
		else:
			should_drag_x = false
			character.set_movement(Vector2(movespeed * movement_sign_offset, character.velocity.y))
	elif should_drag_x:
		if abs(character.velocity.x) > 0.05:
			## Add drag * velociy in the opposite sign of velocity
			character.add_movement((sign(character.velocity) * -1) * Vector2(abs(character.velocity.x * drag_x), 0))
		else:
			character.velocity.x = 0
	## Y-Axis
	if !character.get_grounded():
		## Gravity, else Drag
		if gravity != 0:
			## Gravity is acceleration (add_movement)
			character.add_movement(Vector2(0, gravity))
		elif drag_y != 0:
			if abs(character.velocity.y) > 0.05:
				## Add drag * velociy in the opposite sign of velocity
				character.add_movement((sign(character.velocity) * -1) * Vector2(0, character.velocity.y * drag_y))
			else:
				## If barely moving, zero (idk when this would happen bc in the air we have gravity)
				character.velocity.y = 0
	else:
		character.set_movement(Vector2(character.velocity.x, 0))
	character.process_terminal_velocity(max_velocity_up, max_velocity_down, max_velocity_front, max_velocity_back)
	character.process_movement()
## Helper Methods
func is_facing_right() -> bool:
	return character.facing_right
func is_forward_input() -> bool:
	return (input_state.left && !character.facing_right) || (input_state.right && character.facing_right)
func is_backward_input() -> bool:
	return (input_state.left && character.facing_right) || (input_state.right && !character.facing_right)
func is_blocking() -> bool:
	return (input_state.left && character.facing_right) || (input_state.right && !character.facing_right)  
func is_crouching() -> bool:
	return input_state.down
func is_standing() -> bool:
	return (!input_state.down && !input_state.up)
## Returns if the given CollisionBox comes from this Character or another one
func is_our_box(box: CollisionBox) -> bool:
	return (box.p1 == character.p1) && (box.state == self)
func equals(other: CharacterState) -> bool:
	return other.get_script() == get_script()
## Happens after all process but before state change
func process_unique():
	pass
func disable_all_transitionability():
	stand_transitionable = false
	crouch_transitionable = false
	movement_transitionable = false
	jump_transitionable = false
	dash_transitionable = false
	normal_transitionable = false
	grab_transitionable = false
	special_transitionable = false
	parry_transitionable = false
	super_transitionable = false
	ultimate_transitionable = false
	falling_transitionable = false
	air_dash_transitionable = false
	air_normal_transitionable = false
	air_grab_transitionable = false
	air_special_transitionable = false
	air_super_transitionable = false
	air_ultimate_transitionable = false
	getting_hit_transitionable = false
class StateQueue:
	var queue: Array[StateQueueItem]
	func sort_custom(method: Callable):
		queue.sort_custom(method)
	func force_add(state: CharacterState, buffer: int, args: Array):
		queue.append(StateQueueItem.new(state, buffer, args, true))
	func add_new(state: CharacterState, buffer: int, args: Array):
		queue.append(StateQueueItem.new(state, buffer, args, false))
	func add(state: CharacterState, buffer: int, args: Array):
		for element in queue:
			## If a buffer for this state exists, extend if needed and nothing else
			if element.state.equals(state):
				if element.frames_left < buffer:
					element.frames_left = buffer
				return
		## If a buffer doesn't exist, add_new()
		add_new(state, buffer, args)
	func remove(state: StateQueueItem):
		queue.erase(state)
	func is_empty() -> bool:
		return queue.is_empty()
	func advance_frame():
		for element in queue:
			element.reduce_buffer_or_delete(queue)
	class StateQueueItem:
		var state_switching_priority:
			get():
				return state.state_switching_priority
		var state: CharacterState
		var args: Array
		var frames_left: int = 0
		## Forces this state unless we were hit this frame
		var force_state_unless_hit: bool = false
		func _init(new_state: CharacterState, buffer: int, new_args: Array, force_add: bool):
			state = new_state
			frames_left = buffer
			force_state_unless_hit = force_add
			args = new_args
		func reduce_buffer_or_delete(queue: Array):
			frames_left -= 1
			if frames_left <= 0 && queue.has(self):
				queue.erase(self)
class CollisionQueueElement:
	func _init(new_attack_state: AttackState, new_combo_scaling: float, new_damage_onhit: float, new_damage_onblock: float, new_pushback_onhit: float, new_pushback_onblock: float, new_launch_onhit: bool, new_launch_height: float, new_juggle_height: float, new_overhead: bool, new_low: bool, new_jump_in: bool, new_blockstun: int, new_hitstun: int):
		attack_state = new_attack_state
		combo_scaling = new_combo_scaling
		damage_onhit = new_damage_onhit
		damage_onblock = new_damage_onblock
		pushback_onhit = new_pushback_onhit
		pushback_onblock = new_pushback_onblock
		launch_onhit = new_launch_onhit
		launch_height = new_launch_height
		juggle_height = new_juggle_height
		overhead = new_overhead
		low = new_low
		jump_in = new_jump_in
		blockstun = new_blockstun
		hitstun = new_hitstun
	var attack_state: AttackState
	var combo_scaling: float
	var damage_onhit: float
	var damage_onblock: float
	var pushback_onhit: float
	var pushback_onblock: float
	var launch_onhit: bool
	var launch_height: float
	var juggle_height: float
	var overhead: bool
	var low: bool
	var jump_in: bool
	var blockstun: int
	var hitstun: int
## Checks and returns if this state can currently transition to given state
func transition_to_state(state: CharacterState, force_unless_hit: bool, args: Array) -> bool:
	## Write each out in a match statement so inherited objects can overwrite custom transitions
	state._init()
	if state == self:
		print("trying to transition to self")
		return false
	match state.state_switching_priority:
		StateSwitchingPriorities.stand:
			return transition_to_stand(state, force_unless_hit, args)
		StateSwitchingPriorities.crouch:
			return transition_to_crouch(state, force_unless_hit, args)
		StateSwitchingPriorities.movement:
			return transition_to_movement(state, force_unless_hit, args)
		StateSwitchingPriorities.jump:
			return transition_to_jump(state, force_unless_hit, args)
		StateSwitchingPriorities.dash:
			return transition_to_dash(state, force_unless_hit, args)
		StateSwitchingPriorities.normal:
			return transition_to_normal(state, force_unless_hit, args)
		StateSwitchingPriorities.grab:
			return transition_to_grab(state, force_unless_hit, args)
		StateSwitchingPriorities.special:
			return transition_to_special(state, force_unless_hit, args)
		StateSwitchingPriorities.parry:
			return transition_to_parry(state, force_unless_hit, args)
		StateSwitchingPriorities._super:
			return transition_to_super(state, force_unless_hit, args)
		StateSwitchingPriorities.ultimate:
			return transition_to_ultimate(state, force_unless_hit, args)
		StateSwitchingPriorities.falling:
			return transition_to_falling(state, force_unless_hit, args)
		StateSwitchingPriorities.air_dash:
			return transition_to_air_dash(state, force_unless_hit, args)
		StateSwitchingPriorities.air_normal:
			return transition_to_air_normal(state, force_unless_hit, args)
		StateSwitchingPriorities.air_grab:
			return transition_to_air_grab(state, force_unless_hit, args)
		StateSwitchingPriorities.air_special:
			return transition_to_air_special(state, force_unless_hit, args)
		StateSwitchingPriorities.air_super:
			return transition_to_air_super(state, force_unless_hit, args)
		StateSwitchingPriorities.air_ultimate:
			return transition_to_air_ultimate(state, force_unless_hit, args)
		StateSwitchingPriorities.getting_hit:
			return transition_to_getting_hit(state, force_unless_hit, args)
	return false
## Method for each trasition so inherited objects can override
func transition_to_stand(state: CharacterState, force: bool, args: Array) -> bool:
	if stand_transitionable || force:
		character.change_state(state, args)
		return true
	return false
func transition_to_crouch(state: CharacterState, force: bool, args: Array) -> bool:
	if crouch_transitionable || force:
		character.change_state(state, args)
		return true
	return false
func transition_to_movement(state: CharacterState, force: bool, args: Array) -> bool:
	if movement_transitionable || force:
		character.change_state(state, args)
		return true
	return false
func transition_to_jump(state: CharacterState, force: bool, args: Array) -> bool:
	if jump_transitionable || force:
		character.change_state(state, args)
		return true
	return false
func transition_to_dash(state: CharacterState, force: bool, args: Array) -> bool:
	if dash_transitionable || force:
		character.change_state(state, args)
		return true
	return false
func transition_to_normal(state: CharacterState, force: bool, args: Array) -> bool:
	if normal_transitionable || force:
		character.change_state(state, args)
		return true
	return false
func transition_to_grab(state: CharacterState, force: bool, args: Array) -> bool:
	if grab_transitionable || force:
		character.change_state(state, args)
		return true
	return false
func transition_to_falling(state: CharacterState, force: bool, args: Array) -> bool:
	if falling_transitionable || force:
		character.change_state(state, args)
		return true
	return false
func transition_to_air_dash(state: CharacterState, force: bool, args: Array) -> bool:
	if air_dash_transitionable || force:
		character.change_state(state, args)
		return true
	return false
func transition_to_special(state: CharacterState, force: bool, args: Array) -> bool:
	if special_transitionable || force:
		character.change_state(state, args)
		return true
	return false
func transition_to_parry(state: CharacterState, force: bool, args: Array) -> bool:
	if parry_transitionable || force:
		character.change_state(state, args)
		return true
	return false
func transition_to_super(state: CharacterState, force: bool, args: Array) -> bool:
	if super_transitionable || force:
		character.change_state(state, args)
		return true
	return false
func transition_to_ultimate(state: CharacterState, force: bool, args: Array) -> bool:
	if ultimate_transitionable || force:
		character.change_state(state, args)
		return true
	return false
func transition_to_getting_hit(state: CharacterState, force: bool, args: Array) -> bool:
	if getting_hit_transitionable || force:
		character.change_state(state, args)
		return true
	return false
func transition_to_air_normal(state: CharacterState, force: bool, args: Array) -> bool:
	if air_normal_transitionable || force:
		character.change_state(state, args)
		return true
	return false
func transition_to_air_grab(state: CharacterState, force: bool, args: Array) -> bool:
	if air_grab_transitionable || force:
		character.change_state(state, args)
		return true
	return false
func transition_to_air_special(state: CharacterState, force: bool, args: Array) -> bool:
	if air_special_transitionable || force:
		character.change_state(state, args)
		return true
	return false
func transition_to_air_super(state: CharacterState, force: bool, args: Array) -> bool:
	if air_super_transitionable || force:
		character.change_state(state, args)
		return true
	return false
func transition_to_air_ultimate(state: CharacterState, force: bool, args: Array) -> bool:
	if air_ultimate_transitionable || force:
		character.change_state(state, args)
		return true
	return false
