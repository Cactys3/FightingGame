extends CharacterState

func _init():
	state_name = "Crouch"
	state_switching_priority = StateSwitchingPriorities.crouch
	super()
func enable_state(chara: Character, args: Array):
	super(chara, args)


func check_crouch():
	if !input_state.down:
		state_queue.add(character.stand.instantiate(), stand_buffer, [])
