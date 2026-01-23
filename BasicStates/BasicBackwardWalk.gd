extends CharacterState

func _init():
	state_name = "Back Walk"
	state_switching_priority = StateSwitchingPriorities.movement
	super()
## Check if Still Going Forward
func check_backward_walk():
	if (input_state.right && !character.facing_right) || (input_state.left && character.facing_right):
		pass
	else:
		character.change_state(character.stand.instantiate())
