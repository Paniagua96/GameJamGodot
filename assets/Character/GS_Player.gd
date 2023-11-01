extends CharacterBody3D

@onready var mesh = $Char_Anims
@onready var animTree = $Char_Anims/AnimationTree
@onready var sfxSteps = $Sfx_Step
@onready var timer = $Timer

@export var rotationSpeed = .15

const SPEED = 5.0
const SPEED_RUN = 7.0
const JUMP_VELOCITY = 4.5

var wasDefending = false
var blendAmount = 0

func _ready():
	pass


func _process(delta):	
	# Anims Movement
	var input_dir = Input.get_vector("move_forward", "move_back", "move_right", "move_left")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if Input.is_action_just_pressed("Run"):
		timer.start()
	if Input.is_action_just_released("Run"):
		timer.stop()
	if direction:
		if Input.is_action_pressed("Run"):
			animTree.set("parameters/Movement/transition_request","Run")
		else:
			animTree.set("parameters/Movement/transition_request","Walk")
	else:
		animTree.set("parameters/Movement/transition_request","Idle")
	
	# Anim Attack
	if Input.is_action_pressed("Attack"):
		if not animTree.get("parameters/Attack/active"):
			animTree.set("parameters/Attack/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
	# Anim Defend (Blending)
	if Input.is_action_pressed("Defend"):
		wasDefending = true
		blendAmount += 0.1
		blendAmount = clampf(blendAmount,0,1)
		animTree.set("parameters/Defend 2/blend_amount",blendAmount)		
	else: 
		if blendAmount > 0 and wasDefending:
			blendAmount -= 0.2
			blendAmount = clampf(blendAmount,0,1)
			animTree.set("parameters/Defend 2/blend_amount",blendAmount)
			if blendAmount == 0:
				wasDefending = false



func _physics_process(delta):
	# Add the gravity.
	var my_delta = delta * 62.5
	if not is_on_floor():
		velocity.y -= 9.8 * delta	

	# Physic movement
	var input_dir = Input.get_vector("move_forward", "move_back", "move_right", "move_left")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		var speed = 0
		
		if Input.is_action_pressed("Run"):
			speed = SPEED_RUN
		else:
			speed = SPEED
			
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:		
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	# Rotation
	if input_dir != Vector2.ZERO:
		mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(velocity.x, velocity.z),rotationSpeed)

	move_and_slide()
	
func Anim_Evnt_Walk_Steps():
	sfxSteps.pitch_scale = randf_range(0.8,1.2)
	sfxSteps.play()
	
func Play_Run_StepsSFX():
	print(timer.time_left)
	sfxSteps.pitch_scale = randf_range(1,1.3)
	sfxSteps.play()
	
