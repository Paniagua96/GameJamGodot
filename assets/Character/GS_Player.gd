extends CharacterBody3D

@onready var mesh = $Char_Anims
@onready var animPlayer = $Char_Anims/AnimationPlaye
@onready var animTree = $Char_Anims/AnimationTree

@export var rotationSpeed = .15
const SPEED = 5.0
const SPEED_RUN = 7.0
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
		var speed = 0
		
		if Input.is_action_pressed("Run"):
			speed = SPEED_RUN
			animTree.set("parameters/Transition/transition_request","Run")
#			if animPlayer.current_animation != "Run":
#				animPlayer.play("Run")
		else:
			speed = SPEED
			animTree.set("parameters/Transition/transition_request","Walk")
#			if animPlayer.current_animation != "Walk":
#				animPlayer.play("Walk")
					
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		animTree.set("parameters/Transition/transition_request","Idle")
#		if animPlayer.current_animation != "Idle":
#			animPlayer.play("Idle")
			
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if input_dir != Vector2.ZERO:
		mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(velocity.x, velocity.z),rotationSpeed)

	move_and_slide()
