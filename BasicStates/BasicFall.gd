extends CharacterState

func _init():
	state_name = "Fall"
	state_switching_priority = StateSwitchingPriorities.falling
	super()
## Return to stand if landed ## TODO: Landing Lag?
func check_fall():
	if character.get_grounded():
		state_queue.add(character.stand.instantiate(), stand_buffer)
