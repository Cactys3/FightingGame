extends SpriteFrames
class_name AnimSprites
## Number of frames every sprite is shown for
@export var animation_name: String = "default"
@export var stall: int = 0
## Number of frames current sprite has already been shown for
var count: int = 0
var current_frame: int = 0
## sets up the character to display 'frame' from this animation
func display_frame(frame: int, loop: bool, character: Character):
	var total_frame_duration: int = 0
	if loop:
		var modulo_frame: int = frame % _total_duration()
		for index in get_frame_count(animation_name):
			## Add frame duration of 'index'th frame
			total_frame_duration += _frame_duration(index)
			if total_frame_duration >= modulo_frame:
				current_frame = index
				break
	else:
		var found: bool = false
		for index in get_frame_count(animation_name):
			## Add frame duration of 'index'th frame
			total_frame_duration += _frame_duration(index)
			if total_frame_duration >= frame:
				current_frame = index
				found = true
				break
		if !found:
			printerr("Not Looping but ran out of frames for animation, Frame: " + str(frame) + ", Total Duration: " + str(_total_duration()))
	character.set_sprite(get_frame_texture(animation_name, current_frame))
## Returns if the given **IS** the LAST FRAME, or is greater than it.
func is_at_end(frame: int) -> bool:
	return frame >= _total_duration()
func _frame_duration(frame: int) -> int:
	return int(get_frame_duration(animation_name, frame)) + stall
func _total_duration() -> int:
	var ret: int = 0
	for index in get_frame_count(animation_name):
		ret += _frame_duration(index)
	return ret
