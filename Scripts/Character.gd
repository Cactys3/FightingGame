extends Node2D
class_name Character

@onready var anim: Sprite2D = $Sprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var hurtbox: Area2D = $Hurtbox
var current_state: CharacterState

var velocity: Vector2 = Vector2.ZERO

## Basic States
@export_category("Basic States")
@export_group("Stand")
@onready var stand: CharacterState = preload("uid://dwtaaqwj3tyue").new()
@export var stand_animation: AnimSprites
@export var stand_collision_boxes: Array[CollisionBox]
@export var stand_drag: float

@export_group("Crouch")
@onready var crouch: CharacterState
@export var crouch_animation: AnimSprites
@export var crouch_collision_boxes: Array[CollisionBox]
@export var crouch_drag: float

@export_group("Forward Walk")
@onready var forward_walk: CharacterState = preload("uid://dlkc5nynftvu4").new()
@export var forward_walk_animation: AnimSprites
@export var forward_walk_collision_boxes: Array[CollisionBox]
@export var forward_walk_movespeed: float
@export_group("Backward Walk")
@onready var backward_walk: CharacterState = preload("uid://d0ojokd1muaxr").new()
@export var backward_walk_animation: AnimSprites
@export var backward_walk_collision_boxes: Array[CollisionBox]
@export var backward_walk_movespeed: float
@export_group("Forward Dash")
@onready var forward_dash: CharacterState
@export_group("Backward Dash")
@onready var backward_dash: CharacterState
@export_group("Jump")
@onready var jump: CharacterState
		#- jump squat
		#- airborne
		#- landing squat
	#- jump back
	#- jump forward
## Attack States

## Defense States
@export_group("Stand Block")
@onready var stand_block: CharacterState
@export_group("Crouch Block")
@onready var crouch_block: CharacterState
@export_group("Hitsun")
@onready var hitsun: CharacterState
	#- air block
	#- grounded combo (stand)
	#- grounded combo (crouch)
	#- aerial combo (juggle)

func _ready() -> void:
	change_state(get_stand())
## Called when a state change is decided upon
func change_state(new_state: CharacterState):
	if current_state:
		current_state.disable_state()
		remove_child(current_state)
	current_state = new_state
	new_state.enable_state(self)
	add_child(new_state)
## Called Once Per Frame to Set Character's Sprite, pass in a SpriteFrame's sprite (texture2d)
func set_sprite(sprite: Texture2D):
	if sprite:
		anim.texture = sprite
## Called Once Per Frame to Handle Movement
func process_movement():
	position += velocity
func add_movement(added_velocity: Vector2):
	print("add: " + str(added_velocity))
	velocity += added_velocity
func set_movement(new_velocity: Vector2):
	velocity = new_velocity
## Get State Methods
func get_stand() -> CharacterState:
	stand.basic_setup(stand_animation, stand_collision_boxes, stand_drag, true) ## TODO: calculate facing left?
	return stand
func get_forward_walk() -> CharacterState:
	forward_walk.basic_setup(stand_animation, stand_collision_boxes, stand_drag, true) ## TODO: calculate facing left?
	forward_walk.movement_setup(forward_walk_movespeed, false)
	return forward_walk
func get_backward_walk() -> CharacterState:
	backward_walk.basic_setup(stand_animation, stand_collision_boxes, stand_drag, true) ## TODO: calculate facing left?
	backward_walk.movement_setup(backward_walk_movespeed, false)
	return backward_walk
