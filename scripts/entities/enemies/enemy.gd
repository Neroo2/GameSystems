extends CharacterBody3D


@export var navigationAgent: NavigationAgent3D


var health = 100

const SPEED = 8.0
const JUMP_VELOCITY = 4.5

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	navigationAgent.target_position = get_tree().current_scene.find_child("Player").global_position
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta


	var next_point = navigationAgent.get_next_path_position()
	var direction = global_position.direction_to(next_point).normalized()
	velocity = SPEED * direction



	move_and_slide()


func damage(dmg):
	health -= dmg
	
	if health <= 0:
		queue_free()
