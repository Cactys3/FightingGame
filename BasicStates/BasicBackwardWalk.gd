extends CharacterState

## Sets everything up for Basic Stand State
func basic_setup(new_animation: AnimSprites, new_colliders: Array[CollisionBox], new_drag: float, new_facing_right: bool):
	super(new_animation, new_colliders, new_drag, new_facing_right)
	state_switching_priority = StateSwitchingPriorities.movement
	blocking = true
	drag = 0
func movement_setup(new_movespeed: float, new_stop_momentum: bool):
	super(new_movespeed, new_stop_momentum)

func check_backward():
	## Check if Still Going Forward (we are already going forward)
	if (right_pressed && !facing_right) || (left_pressed && facing_right):
		## If current not moving forward, reset to no movement
		if character.velocity.x < 0 && facing_right || character.velocity.x > 0 && !facing_right:
			character.velocity = Vector2.ZERO
		var sign_offset = -1
		if !facing_right:
			sign_offset = 1
		character.add_movement(Vector2(sign_offset * movespeed, 0))
	else:
		print("Transition to stand - backward walk")
		character.change_state(character.get_stand())
