extends CharacterState

@export var landing_lag_frames: int = 1
## Used by Jump and Aerial normals/specials that add extra landing lag (might be punishable on land
func add_landing_frames(added_frames: int):
	landing_lag_frames += added_frames

func _init():
	state_name = "Fall"
	state_switching_priority = StateSwitchingPriorities.falling
	super()
## Return to stand if landed ## TODO: Landing Lag?
func check_fall():
	if character.get_grounded():
		## TODO: Landing Lag: Add a Punishable/CounterHit/Inactionable stand/crouch state that ISN'T hit/blockstun but you can't move
		## Add method set_counterhit(bool), set_punishcounter(bool), set_lag_frames(added_frames: int) to this new state
		state_queue.add(character.stand.instantiate(), stand_buffer, [])
