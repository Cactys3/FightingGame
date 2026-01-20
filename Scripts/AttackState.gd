extends CharacterState



## Attack State Things that normal states don't have:
# Startup/Active/Recovery Frames
# Counter Hit 
# Punish Countered
# Active Hitbox

## Current Frame Variables, setup each frame
var curr_active: bool = false
var curr_startup: bool = false
var curr_recovery: bool = false


func advance_animation():
	pass
func setup_collision():
	pass
func process_variables():
	if frame > duration && duration > 0:
		pass
func process_inputs():
	pass
func process_collisions():
	pass
func conclude_process():
	pass
