extends StunState

func _init():
	state_name = "HitStun Crouch"
	super()
	stun_priority = StunPriorities.crouch_hitstun
