class_name PlayerControllerUI
extends Control

@export var player_ref: Player

@onready var pc_jump_progress_bar: ProgressBar = %PC_Jump_ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if player_ref:
		player_ref.connect("ui_jump_progress_bar", jump_progress_bar_update)
		init_player_controller_ui(player_ref._min_jump_velocity, player_ref._max_jump_velocity)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func init_player_controller_ui(min_jump_value: float, max_jump_value: float) -> void:
	pc_jump_progress_bar.min_value = min_jump_value
	pc_jump_progress_bar.max_value = max_jump_value

func jump_progress_bar_update(val: float) -> void:
	pc_jump_progress_bar.value = val
