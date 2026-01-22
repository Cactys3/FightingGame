extends CharacterState

func movement_setup(new_movespeed: float, new_stop_momentum: bool):
	super(new_movespeed, new_stop_momentum)

func check_backward():
	## Check if Still Going Forward (we are already going forward)
	if (input_state.right && !character.facing_right) || (input_state.left && character.facing_right):
		## If current not moving forward, reset to no movement
		if character.velocity.x < 0 && character.facing_right || character.velocity.x > 0 && !character.facing_right:
			character.velocity = Vector2.ZERO
		var sign_offset = -1
		if !character.facing_right:
			sign_offset = 1
		character.add_movement(Vector2(sign_offset * movespeed, 0))
	else:
		print("Transition to stand - backward walk")
		character.change_state(character.stand.instantiate())
