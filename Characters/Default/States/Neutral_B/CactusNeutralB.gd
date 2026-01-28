extends AttackState

## Startup: 10 frames
## Active: 7 frames
## Recovery: 16 frames
## BlockStun: 16
## OnBlock: -3
## HitStun: 26
## OnHit: 10

func _init():
	state_name = "Neutral A"
	state_switching_priority = StateSwitchingPriorities.normal
	super()
