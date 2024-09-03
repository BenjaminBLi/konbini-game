extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

### Camera Controls

var mouse_sens = 0.001
var twist_val = 0
var pitch_val = 0

@onready var _twist_pivot := $TwistPivot
@onready var _pitch_pivot := $TwistPivot/PitchPivot
@onready var _cam := $TwistPivot/PitchPivot/Camera3D

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if OS.has_feature("editor"):
		_cam.translate(Vector3(0,0,3))
	else:
		_cam.translate(Vector3(0,0,0))


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):

func _input(event):
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			# rotate(Vector3.UP,-event.relative.x*0.001)
			# rotate_object_local(Vector3.RIGHT,-event.relative.y*0.001)
			twist_val = -event.relative.x * mouse_sens
			pitch_val = -event.relative.y * mouse_sens
		_twist_pivot.rotate_y(twist_val)
		_pitch_pivot.rotate_x(pitch_val)
		_pitch_pivot.rotation.x = clamp(
			_pitch_pivot.rotation.x,
			deg_to_rad(-30),
			deg_to_rad(30),
		)
		twist_val = 0
		pitch_val = 0
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		elif Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


### END Camera Controls

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var cam_basis = _twist_pivot.basis


	var direction = (cam_basis * Vector3(input_vector.x, 0, input_vector.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
