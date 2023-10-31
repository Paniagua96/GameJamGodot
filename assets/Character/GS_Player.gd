extends CharacterBody3D

@onready var mesh = $Char_Anims
@export var rotationSpeed = .15
const SPEED = 5.0
const JUMP_VELOCITY = 4.5


func _physics_process(delta):
	var my_delta = delta * 62.5
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= 9.8 * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_forward", "move_back", "move_right", "move_left")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if input_dir != Vector2.ZERO:
		mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(velocity.x, velocity.z),rotationSpeed)

	move_and_slide()
