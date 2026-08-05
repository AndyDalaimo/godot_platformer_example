## Player Controller Data Visualizer
## Base Node that attaches to Player. Will visualize Player Control details

class_name PlayerControllerDataVisualizer
extends Node

const GRAVITY: float  = 9.8

@onready var debug_mesh: MeshInstance3D = %DebugMesh
@onready var debug_jump_timer: Timer = %DebugJumpTimer

@export var player_ref: Player

## Data Vis Properties for Player Controller
var debug_jump_distance: bool = false
var pc_jump_height: float
var pc_jump_distance: Vector2
var pc_max_floor_velocity: float

## Jump timer tracker values
var jump_timer_in_use: bool = false

func _ready() -> void:
	if player_ref:
		pc_jump_height = _calculate_jump_height(player_ref._jump_velocity)
		pc_jump_distance = _calculate_jump_distance(Vector2(player_ref.velocity.x, player_ref.velocity.z), player_ref._jump_velocity)
		pc_max_floor_velocity = player_ref.SPEED
		player_ref.connect("jump_signal", _debug_on_jump_broadcast)

func _physics_process(_delta: float) -> void:
	if debug_jump_distance: 
		pc_jump_distance = _calculate_jump_distance(Vector2(player_ref.velocity.x, player_ref.velocity.z), player_ref._jump_velocity)
		debug_mesh.position = Vector3(player_ref.position.x + pc_jump_distance.x, player_ref.position.y + 1.0, player_ref.position.z + pc_jump_distance.y)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_pc_data_vis_values"):
		_print_data_vis_values()
		if debug_jump_distance: 
			debug_jump_distance = false
			debug_mesh.visible = false
		else:
			debug_jump_timer.stop() ## Reset timer to avoid timeout signal call
			debug_jump_distance = true
			debug_mesh.visible = true

## Method broadcasted from Player jump signal
func _debug_on_jump_broadcast() -> void:
	debug_jump_distance = false
	debug_jump_timer.start(3.0)
	await debug_jump_timer.timeout
	debug_mesh.visible = false

func _calculate_jump_height(initial_velo_y: float) -> float:
	return (pow(initial_velo_y, 2.0) / (2.0 * GRAVITY))

func _calculate_jump_distance(on_floor_velo: Vector2, initial_velo_y: float) -> Vector2:
	#if on_floor_velo == Vector2.ZERO:
		#if player_ref.player_model:
			#var rotation = fmod(absf(player_ref.player_model.rotation_degrees.y), 360.0)
			#print("rotation: ", rotation)
			#on_floor_velo = Vector2(5.0, 0.0)
			
	var total_time = (2.0 * initial_velo_y) / GRAVITY
	return on_floor_velo * player_ref._air_control_coefficient * total_time 

func _print_data_vis_values() -> void:
	pc_jump_height = _calculate_jump_height(player_ref._jump_velocity)
	pc_jump_distance = _calculate_jump_distance(Vector2(player_ref.velocity.x, player_ref.velocity.z), player_ref._jump_velocity)
	print("PC Jump Height: ", pc_jump_height)
	print("PC Jump distance: ", pc_jump_distance)
