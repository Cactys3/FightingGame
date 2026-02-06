extends AttackState

## Startup: 6 frames
## Active: 4 frames
## Recovery: 8 frames
## BlockStun: 10
## OnBlock: -2
## HitStun: 12
## OnHit: 10

func _init():
	state_name = "Neutral A"
	state_switching_priority = StateSwitchingPriorities.normal
	normal_priority = NormalPriorities.FiveA
	super()
