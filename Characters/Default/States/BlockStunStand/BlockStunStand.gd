extends StunState

func _init():
	state_name = "BlockStun Stand"
	super()
	stun_priority = StunPriorities.stand_blockstun
