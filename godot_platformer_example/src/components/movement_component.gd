class_name MovementComponent
extends Node

enum MOVEMENT_STATE {DEFAULT, GROUNDED, JUMP, FALL}

@export var character: CharacterBody3D
@export var character_body: Node3D
@export var character_camera: Camera3D

@export_category("Movement Properties")
@export var _speed: float = 5.0
@export var _rotation_speed: float = TAU * 2 ## How fast the player Model can rotate around 
@export_range(0, 1.0, 0.1) var _acceleration_lerp_weight: float = 0.5
@export_range(0.0, 1.0, 0.1) var _held_jump_movement_offset: float = 0.5 ## Movement Strength is multiplied by this value to slow player down while powering up jump. Default 1.0 has no change on movement strength

@export_group("Jump")
@export_range(9.0, 25.0, 1.0) var _max_jump_velocity: float = 15.0 ## Jump velocity
@export_range(5.0, 12.0, .25) var _min_jump_velocity: float = 7.5 ## Jump velocity

@export_subgroup("Air Control")
@export_range(0, 1.0, 0.1) var _air_control_coefficient: float = 0.7 ## How fast the Player can move in air
@export_range(0.1, 1.0, 0.05) var _air_control_coyote_timer: float = 0.3 ## Coyote Timer will adjust how long it takes for Movement State to change to "FALLING" and trigger air_control_coefficient

@onready var jump_timer: Timer = %JumpTimer

var _jump_velocity: float = 5.0
var _held_jump_timer: float = 0.0

var _movement_strength: float = 0.0
var _movement_state: MOVEMENT_STATE

const JUMP_VELOCITY = 4.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	_movement_strength = Input.get_action_strength("backward") + \
		Input.get_action_strength("forward") + Input.get_action_strength("left") + \
		Input.get_action_strength("right")
	_movement_strength = clampf(_movement_strength, 0.0, 1.0)
	var direction := (character_camera.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	## Zero y coordinate and normalize to fix camera movement basis
	direction.y = 0
	direction = direction.normalized()
	# Add the gravity.
	if not character.is_on_floor():
		character.velocity += character.get_gravity() * delta
		if _movement_state == MOVEMENT_STATE.FALL:
			# _movement_strength = lerpf(_movement_strength, _movement_strength * _air_control_coefficient, 1.0) ## Lerp this value to adjust for transition to lower air control
			_movement_strength = _movement_strength * _air_control_coefficient ## Fix movement strength inline with air control while player is not grounded
	
	## Handle Jump
	if Input.is_action_just_pressed("jump") and character.is_on_floor():
		jump_timer.start()
		_held_jump_timer = _min_jump_velocity
	if Input.is_action_just_released("jump") and character.is_on_floor() and !jump_timer.is_stopped():
		jump_timer.stop()
		_jump(_jump_velocity)
		_held_jump_timer = _min_jump_velocity
	
	## Clamp jump velo between min and max values
	## 
	if jump_timer.time_left > _min_jump_velocity and _jump_velocity < _max_jump_velocity and (jump_timer.wait_time - jump_timer.time_left > 0.1): 
		_held_jump_timer = (jump_timer.wait_time - jump_timer.time_left) * 6.0
		_jump_velocity = _held_jump_timer + _min_jump_velocity
		## ui_jump_progress_bar.emit(_jump_velocity)
		print("Jump Velocity: ", _jump_velocity)
	
	if !jump_timer.is_stopped():
		_movement_strength = _movement_strength * _held_jump_movement_offset
	
	if direction:
		## TESTING -> Still messing with Acceleration Lerp   
		character.velocity.x = lerpf(character.velocity.x, direction.x * _speed * _movement_strength, _acceleration_lerp_weight) 
		character.velocity.z = lerpf(character.velocity.z, direction.z * _speed * _movement_strength, _acceleration_lerp_weight)
		#velocity.x = direction.x * SPEED * _movement_strength
		#velocity.z = direction.z * SPEED * _movement_strength
		#_run_tilt = velocity.x / SPEED
		#if direction.z > -.7 and direction.z < .7:
			##_run_tilt = lerpf(_run_tilt, 0.0, delta)
			#_run_tilt = 0.0
		# smooth rotate player towards direciton
		character_body.rotation.y = rotate_toward(character_body.rotation.y, 
			atan2(direction.x, direction.z), 
			_rotation_speed * delta
			)
	else:
		character.velocity.x = move_toward(character.velocity.x, 0, _speed)
		character.velocity.z = move_toward(character.velocity.z, 0, _speed)
	
	character.move_and_slide() ## Called at the end of each process for physics updates
	pass

## Player Jump - Variable based on time held
func _jump(jump_velo: float) -> void:
	character.velocity.y = jump_velo
	print("JUMP PRESSED")
	##character.jump_signal.emit()
	_jump_velocity = _min_jump_velocity
	## ui_jump_progress_bar.emit(_jump_velocity)
	_movement_state = MOVEMENT_STATE.JUMP
	await get_tree().create_timer(_air_control_coyote_timer).timeout
	_movement_state = MOVEMENT_STATE.FALL


func _on_character_overlap_body_entered(body: Node3D) -> void:
	pass # Replace with function body.
