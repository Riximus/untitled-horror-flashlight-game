extends CharacterBody3D

@onready var head: Node3D = $Head
@onready var standing_collision_shape: CollisionShape3D = $StandingCollisionShape
@onready var crouching_collision_shape: CollisionShape3D = $CrouchingCollisionShape
@onready var raycast: RayCast3D = $RayCast3D

# Movement constants
const WALKING_SPEED: float   = 5.0
const SPRINTING_SPEED: float = 8.0
const CROUCHING_SPEED: float = 3.0
const JUMP_VELOCITY: float = 4.5

# Player constants
const player_height: float = 1.8

# Movement variables
var current_speed: float = 5.0
var lerp_speed: float = 10.0
var crouching_depth: float = -0.5

# Input variables
var direction: Vector3 = Vector3.ZERO
var mouse_sensitivity: float = 0.4 # TODO: make this a setting so players can change it.

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	# Mouse looking logic
	if event is InputEventMouseMotion:
		var mouse_motion := event as InputEventMouseMotion
		rotate_y(deg_to_rad(-mouse_motion.relative.x * mouse_sensitivity))
		head.rotate_x(deg_to_rad(-mouse_motion.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-85), deg_to_rad(85))

func _physics_process(delta: float) -> void:

	# Handle movement states
	# Crouching
	if Input.is_action_pressed("crouch") and is_on_floor(): # Crouch is dominant over sprinting.
		current_speed = CROUCHING_SPEED
		head.position.y = lerp(head.position.y, player_height + crouching_depth, delta*lerp_speed)
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
	# Standing
	elif not raycast.is_colliding() and not Input.is_action_pressed("crouch"):
		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true
		head.position.y = lerp(head.position.y, player_height, delta*lerp_speed)
		# Sprinting
		if Input.is_action_pressed("sprint"):
			current_speed = SPRINTING_SPEED
		# Walking
		else:
			current_speed = WALKING_SPEED

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and not Input.is_action_pressed("crouch"):
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*lerp_speed)

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
