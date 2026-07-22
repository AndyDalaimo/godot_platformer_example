class_name PlayerControllerDataVisualizer
extends Node


const GRAVITY: float  = 9.8

@export var player_ref: Player

## Data Vis Properties for Player Controller
var pc_jump_height: float
var pc_jump_distance: float

func _ready() -> void:
	if player_ref:
		pc_jump_height = _calculate_jump_height(player_ref._jump_velocity)
		pc_jump_distance = _calculate_jump_distance(player_ref.velocity.x, player_ref._jump_velocity)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_pc_data_vis_values"):
		print_data_vis_values()

func _calculate_jump_height(initial_velo_y: float) -> float:
	return (pow(initial_velo_y, 2) / (2 * GRAVITY))

func _calculate_jump_distance(velo_x: float, initial_velo_y: float) -> float:
	var total_time = initial_velo_y / GRAVITY
	return velo_x * total_time 

func print_data_vis_values() -> void:
	pc_jump_height = _calculate_jump_height(player_ref._jump_velocity)
	pc_jump_distance = _calculate_jump_distance(player_ref.velocity.x, player_ref._jump_velocity)
	print("PC Jump Height: ", pc_jump_height)
	print("PC Jump distance: ", pc_jump_distance)
