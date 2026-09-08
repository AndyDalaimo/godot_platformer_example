class_name CameraComponent
extends Node3D

@export var attached_Object: Node3D

@export_group("Camera")
@export_range(0.001, 0.01, 0.001) var _camera_sens: float = 0.003 ## Camera Sensitivity Coefficient
@export_range(25.0, 70.0, 5.0) var _camera_limit_deg: float = 40.0 ## Limit camera degree to not rotate around player on X-Axis
@export_range(0.2, 1.0, 0.1) var _camera_lag_weight: float = 0.2 ## Lerps Camera Pivot Node onto correct Player position. A lower weight will increase Lag. Capped to not allow player to run past SpringArm

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	_camera_control(event)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	## Camera lerp to player position
	if attached_Object:
		global_position = lerp(global_position, attached_Object.global_position + Vector3(0.0, 1.5,0.0), _camera_lag_weight)


## Handle Camera Movement
## Uses root Node3D as a pivot point to rotate around object
func _camera_control(event) -> void:
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * _camera_sens
		rotation.x -= event.relative.y * _camera_sens
		var limit_radians = deg_to_rad(_camera_limit_deg)
		rotation.x = clampf(rotation.x, -limit_radians, limit_radians)
