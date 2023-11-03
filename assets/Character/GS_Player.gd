extends CharacterBody3D

@onready var mesh = $Char_Anims
@onready var animTree = $Char_Anims/AnimationTree
@onready var timer = $Sfx/Timer
@onready var sfxSteps = $Sfx/Sfx_Step
@onready var sfxAttack = $Sfx/Sfx_Attack
@onready var sfxDefend = $Sfx/Sfx_Defend
@onready var springArm = $SpringArm3D

@export var rotationSpeed = .15

const SPEED = 5.0
const SPEED_RUN = 7.0
const ZOOM_MAX = 4
const ZOOM_MIDDLE = 2
const ZOOM_MIN = 1
const ZOOM_SPEED = 5

var wasDefending = false
var blendAmount = 0
var currentZoom = 0.0
var lvlZoom = 0
var targetZoom = 0
var zoomReachToTarget = false

func _ready():
	var initialZoom = ZOOM_MAX
	lvlZoom = initialZoom
	targetZoom = initialZoom
	currentZoom = initialZoom

@warning_ignore("unused_parameter")
func _process(delta):
	# Anims Movement
	var input_dir = Input.get_vector("move_forward", "move_back", "move_right", "move_left")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		if Input.is_action_pressed("Run"):
			animTree.set("parameters/Movement/transition_request","Run")
		else:
			animTree.set("parameters/Movement/transition_request","Walk")
	else:
		animTree.set("parameters/Movement/transition_request","Idle")
	
	# Anim Attack
	if Input.is_action_just_pressed("Attack"):
		if not animTree.get("parameters/Attack/active"):
			sfxAttack.pitch_scale = randf_range(0.8,1.2)
			sfxAttack.play()
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
	
	#Zoom In/Out
	if Input.is_action_just_released("ZoomIn"):
		CalculateNextLvlZoomIn()
				
		if targetZoom != lvlZoom:
			zoomReachToTarget = false
			targetZoom = lvlZoom
		
	if Input.is_action_just_released("ZoomOut"):
		CalculateNextLvlZoomOut()
		
		if targetZoom != lvlZoom:
			zoomReachToTarget = false
			targetZoom = lvlZoom
	
	#Zoom will be apply only if current zoom has not reached to targetZoom
	ApplyZoom(delta)
	
	#Timer Sfx_Run_Steps
	if Input.is_action_just_pressed("Run") && direction:
		timer.start()
	if Input.is_action_just_released("Run"):
		timer.stop()
	
	#Sfx_Defend
	if Input.is_action_just_pressed("Defend"):
		sfxDefend.pitch_scale = randf_range(0.8,1.2)
		sfxDefend.play()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= 9.8 * delta

	# Physic movement
	var input_dir = Input.get_vector("move_right", "move_left","move_back","move_forward")
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

# Methods for zoom
func CalculateNextLvlZoomIn():
	match lvlZoom:
		ZOOM_MIDDLE:
			lvlZoom = ZOOM_MIN
		ZOOM_MAX:
			lvlZoom = ZOOM_MIDDLE
			
func CalculateNextLvlZoomOut():
	match lvlZoom:
		ZOOM_MIN:
			lvlZoom = ZOOM_MIDDLE
		ZOOM_MIDDLE:
			lvlZoom = ZOOM_MAX

func ApplyZoom(delta):
	if !zoomReachToTarget:
		if currentZoom > targetZoom:
			currentZoom -= ZOOM_SPEED * delta
		elif currentZoom < targetZoom:
			currentZoom += ZOOM_SPEED * delta
		
		zoomReachToTarget = abs(targetZoom - currentZoom) < .02
		springArm.spring_length = currentZoom

# Methods for sfx
func Anim_Evnt_Walk_Steps():
	sfxSteps.pitch_scale = randf_range(0.8,1.2)
	sfxSteps.play()
	
func Play_Run_StepsSFX():
	sfxSteps.pitch_scale = randf_range(1,1.3)
	sfxSteps.play()
	
