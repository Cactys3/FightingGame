extends AttackState

## Startup: 6 frames
## Active: 4 frames
## Recovery: 10 frames
## BlockStun: 12
## OnBlock: -2
## HitStun: 14
## OnHit: 10

## impossible to reaction whiff punish
## 2 frames of leniency for spamming it on block


func _init():
	state_name = "Neutral A"
	state_switching_priority = StateSwitchingPriorities.normal
	normal_priority = NormalPriorities.FiveA
	super()
