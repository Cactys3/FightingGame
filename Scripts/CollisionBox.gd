extends RectangleShape2D
## Class setup as a scene, then used by States as Hitboxes and Hurtboxes
class_name CollisionBox
## True = Hitbox, False = Hurtbox
@export var hitbox: bool
@export var display_debug: bool
## True = p1, False = p2
@export var p1: bool
@export var active_frames: Array[int]
@export var _size: Vector2
@export var _position: Vector2
## Return if this CollisionBox can attack other
func can_attack(other: CollisionBox):
	pass
## Return if this CollisionBox can be attacked by other
func can_be_hit(other: CollisionBox):
	pass
