extends SpriteFrames
class_name AnimSprites
## Number of frames every sprite is shown for
@export var animation_name: String = "default"
@export var stall: int = 1
var frame_duration: 
	get():
		return get_frame_duration(animation_name, current_frame)
## Number of frames current sprite has already been shown for
var count: int = 0
var current_frame: int = 0
func go_next_or_stall(character: Character) -> bool:
	character.set_sprite(get_frame_texture(animation_name, current_frame))
	count += 1
	if (stall + frame_duration) > count:
		return false
	else:
		count = 0
		current_frame += 1
		character.set_sprite(get_frame_texture(animation_name, current_frame))
		return true
func is_at_end() -> bool:
	return current_frame >= get_frame_count(animation_name)
func reset(character: Character):
	current_frame = 0
	count = 0
	character.set_sprite(get_frame_texture(animation_name, current_frame))

func get_total_duration() -> int:
	var ret: int = 0
	for index in get_frame_count(animation_name):
		ret += int(get_frame_duration(animation_name, index))
	return ret
