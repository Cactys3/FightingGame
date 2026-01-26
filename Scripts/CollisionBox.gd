extends CollisionShape2D
## Class setup as a scene, then used by States as Hitboxes and Hurtboxes
class_name CollisionBox
## True = Hitbox, False = Hurtbox
@export var is_hitbox: bool
@export var display_debug: bool
@export var print_debug: bool
## True = p1, False = p2
@export var p1: bool
@export var active_frames: Array[int]
@export var inactive_frames: Array[int]
@export var always_active: bool = false
const hitbox_debug_color: Color = Color(255, 0, 0, 0.1)
const hurtbox_debug_color: Color = Color(0, 0, 255, 0.1)
var active: bool = false
## Return if this CollisionBox can attack other
func can_attack(other: CollisionBox):
	pass
## Return if this CollisionBox can be attacked by other
func can_be_hit(other: CollisionBox):
	pass

func disable(frame: int):
	active = false
	display_debug = false
	visible = false
func enable(frame: int):
	active = true
	if is_hitbox:
		debug_color = hitbox_debug_color
	else:
		debug_color = hurtbox_debug_color
	display_debug = true
	visible = true
