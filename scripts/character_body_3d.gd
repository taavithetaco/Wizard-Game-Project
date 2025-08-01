extends CharacterBody3D

@onready var head: Node3D = $head
@onready var standingCollision: CollisionShape3D = $standingCollision
@onready var crouchingCollision: CollisionShape3D = $crouchingCollision
@onready var ray_cast_3d: RayCast3D = $RayCast3D

var currentSpeed = 8.0
var lerpSpeed = 15.0
const walkSpeed = 6
const sprintSpeed = 8

const crouchSpeed = 3
const crouchDepth = -0.5

const jumpVelocity = 4.5

const mouseVel = 0.25

var direction = Vector3.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouseVel))
		head.rotate_x(deg_to_rad(-event.relative.y * mouseVel))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

	

func _physics_process(delta: float) -> void:
	#crouching logic
	if Input.is_action_pressed("crouch"):
		currentSpeed = crouchSpeed
		head.position.y = lerp(head.position.y, 1.8 + crouchDepth, delta * lerpSpeed)
		standingCollision.disabled = true
		crouchingCollision.disabled = false
	elif !ray_cast_3d.is_colliding():
		standingCollision.disabled = false
		crouchingCollision.disabled = true
		head.position.y = lerp(head.position.y, 1.8, delta * lerpSpeed)
		#sprinting logic
		if Input.is_action_pressed("sprint"):
			currentSpeed = sprintSpeed
		else:
			currentSpeed = walkSpeed
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta  

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jumpVelocity

	# Get the input direction and handle the movement/deceleration.
	var inputDirection := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	direction = lerp(direction,(transform.basis * Vector3(inputDirection.x, 0, inputDirection.y)).normalized(), delta * lerpSpeed)
	
	if direction:
		velocity.x = direction.x * currentSpeed
		velocity.z = direction.z * currentSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, currentSpeed)
		velocity.z = move_toward(velocity.z, 0, currentSpeed)
		
	move_and_slide()
