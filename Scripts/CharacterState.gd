extends Node
## Class meant to store and process the current state that a character is in. State implementations inherit this base class.
class_name CharacterState
var character: Character
var frame: int = 0
var enabled: bool = false
var state_queue: Array[CharacterState]
var active_colliders: Array[CollisionShape2D]
var input_state: Character.InputState
@export_category("Generic Properties")
@export var state_name: String = "Default"
@export var state_switching_priority: StateSwitchingPriorities = StateSwitchingPriorities.stand
enum StateSwitchingPriorities {crouch, stand, movement, jump, dash, normal, grab, special, parry, _super, ultimate, falling, air_dash, air_normal, air_grab, air_special, air_super, air_ultimate, getting_hit}
@export var can_block: bool = false
@export var throwable: bool = true
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
@export var movespeed: float = 0
@export_category("Animation Properties")
@export var loop: bool
@export var animation: AnimSprites
@export var colliders: Array[CollisionBox]
## Current Frame Variables, setup each frame
var pressed_crouch: bool = false
var pressed_jump: bool = false
## Sets this state up as the currently active state for the given character
func enable_state(chara: Character):
	print("Current: " + StateSwitchingPriorities.keys()[self.state_switching_priority] + ", " + state_name)
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
func grab_inputs():
	input_state = character.get_inputs()
func process_inputs():
	check_fall()
	check_forward()
	check_backward()
	check_jump()
	check_crouch()
## Go through each hurtbox and check if any opponent hitboxes are inside it. Go through each hitbox and check if any opponent hurtboxes are inside it.
func process_collisions():
	## for blocking check, just see if we are holding back and not using a move where we can't block
	pass
## Handle changing state based on variables set for this frame
func check_state_queue():
	if state_queue.is_empty():
		return
	## Sort by highest priority
	state_queue.sort_custom(func(a, b): return a.state_switching_priority > b.state_switching_priority)
	## Try by highest priority
	for state in state_queue:
		if transition_to_state(state):
			return
	state_queue.clear()
	## If didn't just change state, reduce state change buffers
	## TODO: save state change buffers on change state and send to next state? probably not need unless i think of a reason it is
	#for state in state_queue:
	#	state.reduce_buffer_or_delete(state_queue)
## Checks and returns if this state can currently transition to given state
func transition_to_state(state: CharacterState) -> bool:
	## Write each out in a match statement so inherited objects can overwrite custom transitions
	if state == self:
		print("trying to transition to self")
		return false
	#print(StateSwitchingPriorities.keys()[state.state_switching_priority])
	match state.state_switching_priority:
		StateSwitchingPriorities.stand:
			return transition_to_stand(state)
		StateSwitchingPriorities.crouch:
			return transition_to_crouch(state)
		StateSwitchingPriorities.movement:
			return transition_to_movement(state)
		StateSwitchingPriorities.jump:
			return transition_to_jump(state)
		StateSwitchingPriorities.dash:
			return transition_to_dash(state)
		StateSwitchingPriorities.normal:
			return transition_to_normal(state)
		StateSwitchingPriorities.grab:
			return transition_to_grab(state)
		StateSwitchingPriorities.special:
			return transition_to_special(state)
		StateSwitchingPriorities.parry:
			return transition_to_parry(state)
		StateSwitchingPriorities._super:
			return transition_to_super(state)
		StateSwitchingPriorities.ultimate:
			return transition_to_ultimate(state)
		StateSwitchingPriorities.falling:
			return transition_to_falling(state)
		StateSwitchingPriorities.air_dash:
			return transition_to_air_dash(state)
		StateSwitchingPriorities.air_normal:
			return transition_to_air_normal(state)
		StateSwitchingPriorities.air_grab:
			return transition_to_air_grab(state)
		StateSwitchingPriorities.air_special:
			return transition_to_air_special(state)
		StateSwitchingPriorities.air_super:
			return transition_to_air_super(state)
		StateSwitchingPriorities.air_ultimate:
			return transition_to_air_ultimate(state)
		StateSwitchingPriorities.getting_hit:
			return transition_to_getting_hit(state)
	return false

## Checks
func check_forward():
	## Forward
	if input_state.left && !character.facing_right:
		state_queue.append(character.forward_walk.instantiate())
	elif input_state.right && character.facing_right:
		state_queue.append(character.forward_walk.instantiate())
func check_backward():
	## Backward
	if input_state.left && character.facing_right:
		state_queue.append(character.backward_walk.instantiate())
	elif input_state.right && !character.facing_right:
		state_queue.append(character.backward_walk.instantiate())
func check_jump():
	if input_state.up:
		state_queue.append(character.jump.instantiate())
func check_crouch():
	if input_state.down:
		state_queue.append(character.crouch.instantiate())
func check_fall():
	if !character.get_grounded():
		state_queue.append(character.fall.instantiate())
func process_movement():
	var movement_sign_offset: int = 1
	if !character.facing_right:
		movement_sign_offset = -1
	if movespeed_sign_negative:
		movement_sign_offset *= -1
	## X-Axis
	var should_drag_x = drag_x != 0
	if movespeed != 0:
		## If already moving in correct direction and moving faster than movespeed, don't overwrite speed, just continue
		if sign(character.velocity.length()) == sign(movespeed * movement_sign_offset) && abs(character.velocity.length()) > abs(movespeed * movement_sign_offset):
			print(str( sign(character.velocity.length()))  + " vs " + str(sign(movespeed * movement_sign_offset)))
			print(str( (character.velocity.length()))  + " vs " + str((movespeed * movement_sign_offset)))
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
	character.process_movement()

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

## Not used as of now
class StateQueue:
	var queue: Array[StateQueueItem]
	func force_add(state: CharacterState, buffer: int):
		var element = StateQueueItem.new(state, buffer)
		element.force_state_unless_hit = true
		queue.append(element)
	func add(state: CharacterState, buffer: int):
		queue.append(StateQueueItem.new(state, buffer))
	func add_or_extend(state: CharacterState, buffer: int):
		for element in queue:
			if element.state == state && element.frames_left < buffer:
				element.frames_left = buffer
				return
		queue.append(StateQueueItem.new(state, buffer))
	func advance_frame():
		for element in queue:
			element.reduce_buffer_or_delete(queue)
	class StateQueueItem:
		var state: CharacterState
		var frames_left: int = 0
		## Forces this state unless we were hit this frame
		var force_state_unless_hit: bool = false
		func _init(new_state: CharacterState, buffer: int):
			state = new_state
			frames_left = buffer
		func reduce_buffer_or_delete(queue: Array):
			frames_left -= 1
			if frames_left <= 0 && queue.has(self):
				queue.erase(self)

## Method for each trasition so inherited objects can override
func transition_to_stand(state: CharacterState) -> bool:
	if stand_transitionable:
		character.change_state(state)
		return true
	return false
func transition_to_crouch(state: CharacterState) -> bool:
	if crouch_transitionable:
		character.change_state(state)
		return true
	return false
func transition_to_movement(state: CharacterState) -> bool:
	if movement_transitionable:
		character.change_state(state)
		return true
	return false
func transition_to_jump(state: CharacterState) -> bool:
	if jump_transitionable:
		character.change_state(state)
		return true
	return false
func transition_to_dash(state: CharacterState) -> bool:
	if dash_transitionable:
		character.change_state(state)
		return true
	return false
func transition_to_normal(state: CharacterState) -> bool:
	if normal_transitionable:
		character.change_state(state)
		return true
	return false
func transition_to_grab(state: CharacterState) -> bool:
	if grab_transitionable:
		character.change_state(state)
		return true
	return false
func transition_to_falling(state: CharacterState) -> bool:
	if falling_transitionable:
		character.change_state(state)
		return true
	return false
func transition_to_air_dash(state: CharacterState) -> bool:
	if air_dash_transitionable:
		character.change_state(state)
		return true
	return false
func transition_to_special(state: CharacterState) -> bool:
	if special_transitionable:
		character.change_state(state)
		return true
	return false
func transition_to_parry(state: CharacterState) -> bool:
	if parry_transitionable:
		character.change_state(state)
		return true
	return false
func transition_to_super(state: CharacterState) -> bool:
	if super_transitionable:
		character.change_state(state)
		return true
	return false
func transition_to_ultimate(state: CharacterState) -> bool:
	if ultimate_transitionable:
		character.change_state(state)
		return true
	return false
func transition_to_getting_hit(state: CharacterState) -> bool:
	if getting_hit_transitionable:
		character.change_state(state)
		return true
	return false
func transition_to_air_normal(state: CharacterState) -> bool:
	if air_normal_transitionable:
		character.change_state(state)
		return true
	return false
func transition_to_air_grab(state: CharacterState) -> bool:
	if air_grab_transitionable:
		character.change_state(state)
		return true
	return false
func transition_to_air_special(state: CharacterState) -> bool:
	if air_special_transitionable:
		character.change_state(state)
		return true
	return false
func transition_to_air_super(state: CharacterState) -> bool:
	if air_super_transitionable:
		character.change_state(state)
		return true
	return false
func transition_to_air_ultimate(state: CharacterState) -> bool:
	if air_ultimate_transitionable:
		character.change_state(state)
		return true
	return false
