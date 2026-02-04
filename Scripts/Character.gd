extends Node2D
class_name Character
@onready var anim: Sprite2D = $Sprite2D
var current_state: CharacterState
var velocity: Vector2 = Vector2.ZERO
var facing_right: bool = true
var ground_ray: RayCast2D = RayCast2D.new()
var p1: bool
## Basic States
@export_group("Ground States")
@export var stand: PackedScene
@export var crouch: PackedScene
@export var forward_walk: PackedScene 
@export var backward_walk: PackedScene
@export var forward_dash: PackedScene
@export var backward_dash: PackedScene
@export_group("Air States")
@export var jump: PackedScene
@export var fall: PackedScene
## Attack States
@export_group("Attack States")
@export var five_A: PackedScene
@export var five_B: PackedScene
@export var five_C: PackedScene
@export var five_d: PackedScene
@export var six_A: PackedScene
@export var six_B: PackedScene
@export var six_C: PackedScene
@export var six_d: PackedScene
@export var two_A: PackedScene
@export var two_B: PackedScene
@export var two_C: PackedScene
@export var two_d: PackedScene
@export var four_A: PackedScene
@export var four_B: PackedScene
@export var four_C: PackedScene
@export var four_d: PackedScene
@export var three_A: PackedScene
@export var three_B: PackedScene
@export var three_C: PackedScene
@export var three_d: PackedScene
@export var one_A: PackedScene
@export var one_B: PackedScene
@export var one_C: PackedScene
@export var one_d: PackedScene
## Defense States
@export_group("Defense States")
@export var stand_blockstun: PackedScene
@export var stand_hitsun: PackedScene
@export var crouch_blockstun: PackedScene
@export var crouch_hitsun: PackedScene
@export var air_blockstun: PackedScene
@export var air_hitsun: PackedScene
	#- air block
	#- grounded combo (stand)
	#- grounded combo (crouch)
	#- aerial combo (juggle)

#func process_frame():
	#if current_state:
		#current_state.process_frame()

## Individual Calls to process state
func process_advance_frame():
	await current_state.advance_frame()
func process_advance_animation():
	await current_state.advance_animation()
func process_setup_collision():
	await current_state.setup_collision()
func process_process_variables():
	await current_state.process_variables()
func process_grab_inputs():
	await current_state.grab_inputs()
func process_process_inputs():
	await current_state.process_inputs()
func process_process_collisions():
	await current_state.process_collisions()
func process_process_movement():
	await current_state.process_movement()
func process_process_unique():
	await current_state.process_unique()
func process_check_state_queue():
	await current_state.check_state_queue()

func _ready() -> void:
	get_tree().debug_collisions_hint = true
	add_child(ground_ray)
	ground_ray.enabled = true
	ground_ray.target_position = ground_ray.position + Vector2(0, 70)
	ground_ray.collide_with_areas = true
	ground_ray.collide_with_bodies = true
	change_state(stand.instantiate(), [])
## Called when a state change is decided upon
func change_state(new_state: CharacterState, args: Array):
	if current_state:
		current_state.disable_state()
		remove_child(current_state)
		current_state.queue_free()
	current_state = new_state
	new_state.enable_state(self, args)
	add_child(new_state)
## Called Once Per Frame to Set Character's Sprite, pass in a SpriteFrame's sprite (texture2d)
func set_sprite(sprite: Texture2D):
	if current_state.is_facing_right():
		scale.x = 1
	else:
		scale.x = -1
	if sprite:
		anim.texture = sprite
## Called Once Per Frame to Handle Movement
func process_movement():
	position += velocity
func process_terminal_velocity(up, down, front, back):
	if up != 0 && sign(velocity.y) < 0 && velocity.abs().y > abs(up):
		velocity.y =  -abs(up)
	if down != 0 && sign(velocity.y) > 0 && velocity.abs().y > abs(down):
		velocity.y =  abs(down)
	var facing_direction_offset: int = 1
	if !facing_right:
		facing_direction_offset = -1
	if front != 0 && sign(velocity.x) < 0 && velocity.abs().x > abs(front):
		velocity.x =  -abs(front) * facing_direction_offset
	if back != 0 && sign(velocity.x) > 0 && velocity.abs().x > abs(back):
		velocity.x =  abs(back) * facing_direction_offset
func add_movement(added_velocity: Vector2):
	velocity += added_velocity
func set_movement(new_velocity: Vector2):
	velocity = new_velocity
## Returns a setup InputState based on InputBuffer and Input.action_pressed
func get_inputs() -> InputState:
	var state: InputState = GameManager.instance.get_inputs(p1)
	return state
func get_grounded() -> bool:
	if ground_ray.is_colliding():
		return ground_ray.get_collider().is_in_group("ground")
	return false
## A bool for each standard input, used for sending current InputState to a CharacterState
class InputState:
	## Movement
	var up: bool = false
	var down: bool = false
	var left: bool = false
	var right: bool = false
	## Normals
	var A: bool = false
	var B: bool = false
	var C: bool = false
	## Menus
	var start: bool = false
	var back: bool = false
	## Motion Inputs (ew, traditional notation)
	## Quarter Circle Forward
	var qcf: bool = false
	## Quarter Circle Back
	var qcb: bool = false
	## Half Circle Forward
	var hcf: bool = false
	## Half Circle Back
	var hcb: bool = false
	## Z Input Forward
	var dpf: bool = false
	## Z Input Back
	var dpb: bool = false
	## 360 Input
	var fullcircle: bool = false
