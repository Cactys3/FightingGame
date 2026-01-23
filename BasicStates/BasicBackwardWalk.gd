extends CharacterState

## Check if Still Going Forward
func check_backward():
	if (input_state.right && !character.facing_right) || (input_state.left && character.facing_right):
		pass
	else:
		character.change_state(character.stand.instantiate())
