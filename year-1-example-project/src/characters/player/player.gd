extends CharacterBody3D


@export var _rotation_speed: float = TAU * 2

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var tilt: float = 0.0

@onready var player_model = %godot_plush_model
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var animation_tree: AnimationTree = %AnimationTree

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		if velocity == Vector3.ZERO:
			animation_player.current_animation = "idle"
		pass

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var movement_strength := Input.get_action_strength("backward") + \
		Input.get_action_strength("forward") + Input.get_action_strength("left") + \
		Input.get_action_strength("right")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED * movement_strength
		velocity.z = direction.z * SPEED * movement_strength
		#tilt = velocity.x / SPEED
		#if direction.z > -.7 and direction.z < .7:
			##tilt = lerpf(tilt, 0.0, delta)
			#tilt = 0.0
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
