extends VBoxContainer
class_name InputHistory
const max_history: int = 15
## Adds the 'text' as an item in Input History
func add(text: String):
	var addition: RichTextLabel = RichTextLabel.new()
	addition.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	#addition.size_flags_vertical = size
	addition.fit_content = true
	addition.scroll_active = false
	addition.add_theme_font_size_override("normal_font_size", 12)
	addition.text = text
	add_child(addition)
	move_child(addition, 0)
	_trim_history()
## Changes the input text of input history at 'index' to 'text'
func change(text: String, index: int):
	var child: RichTextLabel = get_child(index)
	if child: 
		child.text = text
	elif index == 0:
		add(text)
## Helper method to 
func _trim_history():
	var accidents: int = get_child_count() - max_history
	if accidents > 0:
		for i in accidents:
			var child = get_child(get_child_count() - 1)
			remove_child(child)
			child.queue_free()
