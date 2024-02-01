extends CharacterBody3D

@onready var head: Node3D = $Head
@onready var eyes: Node3D = $Head/Eyes
@onready var hand: Node3D = $Hand

@onready var standing_collision_shape: CollisionShape3D = $StandingCollisionShape
@onready var crouching_collision_shape: CollisionShape3D = $CrouchingCollisionShape
@onready var above_head_raycast: RayCast3D = $AboveHeadRayCast

@onready var camera: Camera3D = $Head/Eyes/Camera3D

@onready var pickup_pos: Node3D = $Head/Eyes/Camera3D/PickupPos
@onready var flashlight: SpotLight3D = $Hand/SpotLight3D
@onready var animation_player: AnimationPlayer = $Head/Eyes/AnimationPlayer

# Movement constants
const WALKING_SPEED: float   = 5.0
const SPRINTING_SPEED: float = 8.0
const CROUCHING_SPEED: float = 3.0
const JUMP_VELOCITY: float = 4.5
# pickup and drop
const PICKUP_LENGTH: float = 2

# Player constants
const player_height: float = 1.8

# Movement variables
var current_speed: float = 5.0
var lerp_speed: float = 10.0
var air_lerp_speed: float = 1.5
var crouching_depth: float = -0.5
var last_velocity: Vector3 = Vector3.ZERO

# Head bobbing variables
var head_bobbing_speed: float = 0.0
var head_bobbing_intensity: float = 0.0
var head_bobbing_current_intensity: float = 0.0
var head_bobbing_index: float = 0.0
var head_bobbing_vector: Vector2 = Vector2.ZERO

# Player state enum
enum PLAYER_STATE { IDLE, WALKING, SPRINTING, CROUCHING, JUMPING }
var current_player_state: PLAYER_STATE = PLAYER_STATE.IDLE

var head_bobbing: Dictionary = { # TODO: make this a setting so players can change it.
	PLAYER_STATE.IDLE: {
	   "speed": 0,
	   "intensity": 0
	},
	PLAYER_STATE.WALKING: {
	   "speed": 14.0,
	   "intensity": 0.1
	},
	PLAYER_STATE.SPRINTING: {
	   "speed": 22.0,
	   "intensity": 0.2
	},
	PLAYER_STATE.CROUCHING: {
	   "speed": 10.0,
	   "intensity": 0.05
	},
	PLAYER_STATE.JUMPING: {
	   "speed": 0,
	   "intensity": 0
	}
}

# Input variables
var direction: Vector3 = Vector3.ZERO
var mouse_sensitivity: float = 0.4 # TODO: make this a setting so players can change it.

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var cur_item: Item = null

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	# Mouse looking logic
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var mouse_motion := event as InputEventMouseMotion
		rotate_y(deg_to_rad(-mouse_motion.relative.x * mouse_sensitivity))
		head.rotate_x(deg_to_rad(-mouse_motion.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-85), deg_to_rad(85))

	if event.is_action_pressed("primary_action"):
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event.is_action_pressed("pickup") and not cur_item:
		var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
		var result: Dictionary = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(
			camera.global_position, camera.global_position-camera.global_transform.basis.z.normalized()*PICKUP_LENGTH))

		if result and result.collider.is_in_group("Item"):
			cur_item = result.collider
			cur_item.freeze = true
			cur_item.get_node("CollisionShape3D").disabled = true
			cur_item.reparent(pickup_pos)
	if event.is_action_pressed("drop") and cur_item:
		cur_item.get_node("CollisionShape3D").disabled = false
		cur_item.reparent(get_parent())
		cur_item.freeze = false
		cur_item = null

func _physics_process(delta: float) -> void:
	# Handle movement states
	var input_dir := Input.get_vector("left", "right", "forward", "backward")

	if is_on_floor():
		# Idle
		if input_dir == Vector2.ZERO and is_on_floor():
			current_player_state = PLAYER_STATE.IDLE
		# Crouching
		elif Input.is_action_pressed("crouch") and is_on_floor(): # Crouch is dominant over sprinting.
			current_player_state = PLAYER_STATE.CROUCHING
			current_speed = lerp(current_speed, CROUCHING_SPEED, delta*lerp_speed)
			head.position.y = lerp(head.position.y, player_height + crouching_depth, delta*lerp_speed)
			standing_collision_shape.disabled = true
			crouching_collision_shape.disabled = false
			# Standing
		elif not above_head_raycast.is_colliding() and not Input.is_action_pressed("crouch"):
			standing_collision_shape.disabled = false
			crouching_collision_shape.disabled = true
			head.position.y = lerp(head.position.y, player_height, delta*lerp_speed)
			# Sprinting
			if Input.is_action_pressed("sprint"):
				current_player_state = PLAYER_STATE.SPRINTING
				current_speed = lerp(current_speed, SPRINTING_SPEED, delta*lerp_speed)
				# Walking
			else:
				current_player_state = PLAYER_STATE.WALKING
				current_speed = lerp(current_speed, WALKING_SPEED, delta*lerp_speed)

	if cur_item:
		cur_item.global_position = lerp(cur_item.global_position, pickup_pos.global_position, delta*lerp_speed)
		cur_item.global_rotation = lerp(cur_item.global_rotation, pickup_pos.global_rotation, delta*lerp_speed)

	# Handle head bobbing
	if is_on_floor() and not current_player_state == PLAYER_STATE.IDLE:
		head_bobbing_speed = head_bobbing[current_player_state]["speed"]
		head_bobbing_intensity = head_bobbing[current_player_state]["intensity"]
		
		head_bobbing_current_intensity = head_bobbing_intensity
		head_bobbing_index += head_bobbing_speed*delta
		
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index/2)+0.5
		
		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y*(head_bobbing_current_intensity/2.0),delta*lerp_speed)
		eyes.position.x = lerp(eyes.position.x, head_bobbing_vector.x*(head_bobbing_current_intensity),delta*lerp_speed)
		
	else: 
		eyes.position.y = lerp(eyes.position.y, 0.0, delta*lerp_speed)
		eyes.position.x = lerp(eyes.position.x, 0.0, delta*lerp_speed)
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and not Input.is_action_pressed("crouch"):
		current_player_state = PLAYER_STATE.JUMPING
		velocity.y = JUMP_VELOCITY
		animation_player.play("jump")

	# Get the input direction and handle the movement/deceleration.
	if is_on_floor():
		# Handle landing
		if last_velocity.y < 0.0:
			animation_player.play("landing")
		
		direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*lerp_speed)
	else:
		if input_dir != Vector2.ZERO:
			direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*air_lerp_speed)
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	last_velocity = velocity
	move_and_slide()
