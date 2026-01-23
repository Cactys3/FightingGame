extends CharacterState

func check_crouch():
	if !input_state.down:
		state_queue.append(character.stand.instantiate())
