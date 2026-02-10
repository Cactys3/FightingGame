extends StunState

func _init():
	super()
	state_name = "BlockStun Crouch"
	stun_priority = StunPriorities.crouch_blockstun
