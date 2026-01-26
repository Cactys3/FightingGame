extends AttackState

## Startup: 10 frames
## Active: 7 frames
## Recovery: 17 frames
## BlockStun: 18
## OnBlock: -2
## HitStun: 26
## OnHit: 10

func _init():
	state_name = "Neutral B"
	state_switching_priority = StateSwitchingPriorities.normal
	super()
