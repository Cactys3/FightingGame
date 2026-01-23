extends CharacterState

func _init():
	state_name = "Front Walk"
	state_switching_priority = StateSwitchingPriorities.movement
	super()
## Check if Still Going Forward
func check_forward_walk():
	if (input_state.right && character.facing_right) || (input_state.left && !character.facing_right):
		pass
	else:
		character.change_state(character.stand.instantiate())
