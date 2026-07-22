class_name Player
extends CharacterBody3D

enum MOVEMENT_STATE {DEFAULT, GROUNDED, JUMP, FALL}

@export_category("Movement Properties")
@export var _rotation_speed: float = TAU * 2 ## How fast the player Model can rotate around 
@export var _jump_velocity: float = 4.5 ## Jump velocity
@export_range(0, 1.0, 0.1) var _air_control_coefficient: float = 0.7 ## How fast the Player can move in air
@export_range(0.1, 1.0, 0.05) var _air_control_coyote_timer: float = 0.3 ## Coyote Timer will adjust how long it takes for Movement State to change to "FALLING" and trigger air_control_coefficient
@export_range(0, 1.0, 0.1) var _acceleration_lerp_weight: float = 0.5

@export_category("Player Controller Properties")
@export_range(0.001, 0.01, 0.001) var _camera_sens: float = 0.003 ## Camera Sensitivity Coefficient
@export_range(25.0, 70.0, 5.0) var _camera_limit_deg: float = 40.0 ## Limit camera degree to not rotate around player on X-Axis
@export_range(0.2, 1.0, 0.1) var _camera_lag_weight: float = 0.2 ## Lerps Camera Pivot Node onto correct Player position. A lower weight will increase Lag. Capped to not allow player to run past SpringArm


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var player_model = %godot_plush_model
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var animation_tree: AnimationTree = %AnimationTree
@onready var anim_state_machine = animation_tree.get("parameters/playback")
@onready var camera_pivot: Node3D = %CameraPivot
@onready var camera_3d: Camera3D = %Camera3D

## Variable Player Movement properties
var _run_tilt: float = 0.0
var _movement_strength: float = 0.0
var _movement_state: MOVEMENT_STATE

## Data vis 

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	## Handle Camera Movement
	_camera_control(event)
	
	## Handle Jump
	if event.is_action_pressed("jump") and is_on_floor():
		velocity.y = _jump_velocity
		#anim_state_machine.travel("up")
		_movement_state = MOVEMENT_STATE.JUMP
		await get_tree().create_timer(_air_control_coyote_timer).timeout
		_movement_state = MOVEMENT_STATE.FALL
		
		print("Jump Height: ", absf((pow(_jump_velocity, 2)) / (2 * get_gravity().y))) ## Calculating Jump height for better data Vis
		print("Jump Distance: ", )
	

func _physics_process(delta: float) -> void:
	## Camera lerp to player position
	camera_pivot.global_position = lerp(camera_pivot.global_position, player_model.global_position + Vector3(0.0, 1.5,0.0), _camera_lag_weight)
	
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	_movement_strength = Input.get_action_strength("backward") + \
		Input.get_action_strength("forward") + Input.get_action_strength("left") + \
		Input.get_action_strength("right")
	_movement_strength = clampf(_movement_strength, 0.0, 1.0)
	var direction := (camera_3d.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	## Zero y coordinate and normalize to fix camera movement basis
	direction.y = 0
	direction = direction.normalized()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		if _movement_state == MOVEMENT_STATE.FALL:
			_movement_strength = lerpf(_movement_strength, _movement_strength * _air_control_coefficient, 0.1) ## Lerp this value to adjust for transittion to lower air control
			# _movement_strength = _movement_strength * _air_control_coefficient ## Fix movement strength inline with air control while player is not grounded
		
	if direction:
		## TESTING -> Still messing with Acceleration Lerp   
		velocity.x = lerpf(velocity.x, direction.x * SPEED * _movement_strength, _acceleration_lerp_weight) 
		velocity.z = lerpf(velocity.z, direction.z * SPEED * _movement_strength, _acceleration_lerp_weight)
		#velocity.x = direction.x * SPEED * _movement_strength
		#velocity.z = direction.z * SPEED * _movement_strength
		#_run_tilt = velocity.x / SPEED
		#if direction.z > -.7 and direction.z < .7:
			##_run_tilt = lerpf(_run_tilt, 0.0, delta)
			#_run_tilt = 0.0
		# smooth rotate player towards direciton
		player_model.rotation.y = rotate_toward(player_model.rotation.y, 
			atan2(direction.x, direction.z), 
			_rotation_speed * delta
			)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	# Animation idle-walk-run blendspace
	var velo = get_real_velocity().length() / SPEED
	animation_tree.set("parameters/idle-walk-run/blend_position", abs(velo))
	
	move_and_slide()

## Handle Camera Movement
func _camera_control(event) -> void:
	if event is InputEventMouseMotion:
		camera_pivot.rotation.y -= event.relative.x * _camera_sens
		camera_pivot.rotation.x -= event.relative.y * _camera_sens
		var limit_radians = deg_to_rad(_camera_limit_deg)
		camera_pivot.rotation.x = clampf(camera_pivot.rotation.x, -limit_radians, limit_radians)
