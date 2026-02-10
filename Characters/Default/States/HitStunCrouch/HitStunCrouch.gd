extends StunState

func _init():
	super()
	state_name = "HitStun Crouch"
	stun_priority = StunPriorities.crouch_hitstun
