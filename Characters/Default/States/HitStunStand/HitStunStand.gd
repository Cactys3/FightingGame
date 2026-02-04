extends StunState

func _init():
	state_name = "HitStun Stand"
	super()
	stun_priority = StunPriorities.stand_hitstun
