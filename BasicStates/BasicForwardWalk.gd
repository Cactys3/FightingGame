extends CharacterState

var initial_facing_right: bool

func enable_state(chara: Character):
	super(chara)
	initial_facing_right = chara.facing_right

func _init():
	state_name = "Front Walk"
	state_switching_priority = StateSwitchingPriorities.movement
	super()
## Check if Still Going Forward
func check_forward_walk():
	if (input_state.right && initial_facing_right) || (input_state.left && !initial_facing_right): #if (input_state.right && character.facing_right) || (input_state.left && !character.facing_right):
		pass
	else:
		state_queue.force_add(character.stand.instantiate(), 0, [])

func is_facing_right() -> bool:
	return initial_facing_right
