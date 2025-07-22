extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export_category("General")
@export var state_machine: StateChart
@export var animation_player: AnimationPlayer

@export_category("MovementVars")
@export var walkingSpeed: int
@export var runningSpeed: int
var current_speed: int = 2


#Character Nodes
@onready var player_model: Node3D = $playerModel
@onready var armature: Node3D = $playerModel/Armature

#Cameras Nodes
@onready var cam_holder: Node3D = $camHolder
@onready var spring_arm: SpringArm3D = $camHolder/springArm
@onready var camera: Camera3D = $camHolder/springArm/Camera

#Bob vars
var bob_time := 0.0
var bob_amount := 0.05
var bob_speed := 8.0
var default_cam_position := Vector3.ZERO

#Float vars
@onready var weapon_positions: Node3D = %WeaponPositions

var float_amplitude := 0.25 
var float_speed := 2.0        
var original_position := Vector3.ZERO


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	default_cam_position = cam_holder.position
	original_position = weapon_positions.global_position

	
func _unhandled_input(event: InputEvent) -> void:
	camera_movement(event)


func _process(delta: float) -> void:
	var time = Time.get_ticks_msec() / 1000.0
	var y_offset = sin(time * float_speed) * float_amplitude
	weapon_positions.global_position.y = original_position.y + y_offset

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	


	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY


	move_and_slide()

func movement_handling(delta):
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * current_speed
			velocity.z = direction.z * current_speed
			armature.rotation.y = lerp_angle(armature.rotation.y, atan2(velocity.x, velocity.z), .15)

		else:
			velocity.x = move_toward(velocity.x, 0, current_speed)
			velocity.z = move_toward(velocity.z, 0, current_speed)
	else:
			velocity.x = lerp(velocity.x, direction.x * current_speed, delta * 4.0)
			velocity.z = lerp(velocity.z, direction.z * current_speed, delta * 4.0)
		
		
	move_and_slide()

func update_camera_bobbing(delta: float):
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	var speed = horizontal_velocity.length()

	if speed > 0.1 and is_on_floor():
		bob_time += delta * bob_speed * (speed / current_speed)
		var bob_offset_y = sin(bob_time) * bob_amount
		var bob_offset_x = sin(bob_time * 2.0) * bob_amount * 0.5
		cam_holder.position = default_cam_position + Vector3(bob_offset_x, bob_offset_y, 0)
	else:
		cam_holder.position = cam_holder.position.lerp(default_cam_position, delta * 5)




func verify_state():
	if velocity.length() > 0 and is_on_floor() and Input.is_action_pressed("run"):
		state_machine.send_event("toRun")
	elif velocity.length() > 0 and is_on_floor() and !Input.is_action_pressed("run"):
		state_machine.send_event("toWalk")
	elif Input.is_action_just_pressed("jump"):
		state_machine.send_event("toJump")
	elif velocity.y < 0:
		state_machine.send_event("toFalling")
	else:
		state_machine.send_event("toIdle")

func camera_movement(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * 0.05))
		player_model.rotate_y(deg_to_rad(event.relative.x * 0.05))
		cam_holder.rotate_x(deg_to_rad(-event.relative.y * 0.05))
		cam_holder.rotation.x = clamp(cam_holder.rotation.x, deg_to_rad(-90), deg_to_rad(90))


#On enter states
func _on_idle_state_state_entered() -> void:
	animation_player.play("Idle")

func _on_walk_state_state_entered() -> void:
	animation_player.play("Walking")
	animation_player.speed_scale = 1.5
	current_speed = walkingSpeed
	bob_amount = 0.05
	bob_speed = 4

func _on_run_state_state_entered() -> void:
	animation_player.play("Running")
	current_speed = runningSpeed
	bob_amount = 0.05
	bob_speed = 8
	
func _on_jump_state_state_entered() -> void:
	animation_player.play("Jumping")


func _on_falling_state_state_entered() -> void:
	animation_player.play("Falling")
	bob_amount = 0.08
	bob_speed = 8


#On state physics processing
func _on_idle_state_state_physics_processing(delta: float) -> void:
	verify_state()
	movement_handling(delta)
	camera.fov = lerp(camera.fov, 75.0, 1 * delta)

func _on_walk_state_state_physics_processing(delta: float) -> void:
	verify_state()
	movement_handling(delta)
	camera.fov = lerp(camera.fov, 80.0, 1 * delta)
	update_camera_bobbing(delta)

func _on_run_state_state_physics_processing(delta: float) -> void:
	verify_state()
	movement_handling(delta)
	update_camera_bobbing(delta)
	camera.fov = lerp(camera.fov, 100.0, 1 * delta)


func _on_jump_state_state_physics_processing(delta: float) -> void:
	verify_state()
	movement_handling(delta)
	


func _on_falling_state_state_physics_processing(delta: float) -> void:
	verify_state()
	movement_handling(delta)
	update_camera_bobbing(delta)
