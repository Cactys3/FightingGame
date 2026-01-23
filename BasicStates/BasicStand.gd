extends CharacterState

func _init():
	state_name = "Stand"
	state_switching_priority = StateSwitchingPriorities.stand
	super()
