extends CharacterState

func _init():
	state_switching_priority = StateSwitchingPriorities.normal

## Attack State Things that normal states don't have:
# Startup/Active/Recovery Frames
# Counter Hit 
# Punish Countered
# Active Hitbox

## Current Frame Variables, setup each frame
var curr_active: bool = false
var curr_startup: bool = false
var curr_recovery: bool = false
