extends CharacterState
class_name StunState
enum StunPriorities {unset, crouch_blockstun, stand_blockstun, crouch_hitstun, stand_hitstun}
var stun_priority: StunPriorities = StunPriorities.unset
var stun_frames: int 



func _init():
	state_name = "Stun"
	super()
	state_switching_priority = StateSwitchingPriorities.getting_hit

func enable_state(chara: Character, args: Array):
	super(chara, args)
	print("is args?")
	if args[0] is CollisionQueueElement:
		print("it is")
		var attack: CollisionQueueElement = args[0]
		if is_blockstun():
			print("1")
			stun_frames = attack.blockstun
		elif is_hitstun():
			print("2")
			stun_frames = attack.hitstun

func is_blockstun() -> bool:
	return stun_priority == StunPriorities.crouch_blockstun || stun_priority == StunPriorities.crouch_blockstun
func is_hitstun() -> bool:
	return stun_priority == StunPriorities.crouch_hitstun || stun_priority == StunPriorities.crouch_hitstun

func process_unique():
	print("Frame: " + str(frame) + " Stun Frame: " + str(stun_frames))
	if frame >= stun_frames:
		if is_crouching():
			state_queue.force_add(character.crouch.instantiate(), stand_buffer, [])
		else:
			state_queue.force_add(character.stand.instantiate(), stand_buffer, [])
