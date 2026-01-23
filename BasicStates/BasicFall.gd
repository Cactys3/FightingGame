extends CharacterState
## Return to stand if landed ## TODO: Landing Lag?
func check_fall():
	if character.get_grounded():
		state_queue.append(character.stand.instantiate())
