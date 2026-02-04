extends StunState

func _init():
	state_name = "BlockStun Crouch"
	super()
	stun_priority = StunPriorities.crouch_blockstun
