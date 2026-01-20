extends Node
## Class meant to store and process the current state that a character is in. State implementations inherit this base class.
class_name CharacterState
var character: Character
var frame: int = 0
var enabled: bool = false


enum StateTypes {idle, attack}
var state_name: String = "DefaultState"
var state_type: StateTypes ## Maybe don't use enums, maybe don't even need a 'type' variable
## Ideas for properties (might not have any of these properties, might just have everything be in the script)
@export_category("Generic Properties")
@export var blocking: bool = false
@export var throwable: bool = true
@export_category("Movement/Physics")
@export var crouching: bool = false
@export var airborne: bool = false
@export var keep_momentum: bool = true
@export var drag: float = 0.5
@export var gravity: float = 9.8
@export_category("Frame Properties")
## Total Frame Duration of this State 
@export var duration: int = 1
@export_category("Animation Properties")
@export var animation: SpriteFrames
@export var hitboxes: Array
@export var hurtboxes: Array


## Current Frame Variables, setup each frame
var pressed_crouch: bool = false
var pressed_jump: bool = false


## Sets this state up as the currently active state for the given character
func enable_state(chara: Character):
	character = chara
	frame = 0
	enabled = true
## Disables this state when transitioning to another state
func disable_state():
	pass
## 60 FPS Process
func _physics_process(_delta: float) -> void:
	if !enabled:
		return
	advance_frame()
	advance_animation()
	setup_collision()
	process_variables()
	process_inputs()
	process_collisions()
	## Conclude Process and handle potential state change:
## Process Methods
func advance_frame():
	frame += 1 
## Set Animation based on framecount, loop if desired
func advance_animation():
	pass
## Setup/Enable hurt/hitboxes based on framecount 
func setup_collision():
	pass
## Set Variables that happen at specific times during animations/states
func process_variables():
	if frame > duration && duration > 0:
		pass
## Go through each input and check if it's being pressed, then set boolean var values for this frame to be handled in end step
func process_inputs():
	pass
## Go through each hurtbox and check if any opponent hitboxes are inside it. Go through each hitbox and check if any opponent hurtboxes are inside it.
func process_collisions():
	pass
## Handle changing state based on variables set for this frame
func conclude_process():
	pass
