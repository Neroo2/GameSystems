extends CharacterBody3D

signal enemyDeath


@export var navigationAgent: NavigationAgent3D
@export var expAmount: float
@export var enemyMesh: MeshInstance3D
var player: CharacterBody3D = null


var health = 100

const SPEED = 8.0
const JUMP_VELOCITY = 4.5

func _ready() -> void:
	player = get_tree().current_scene.find_child("Player")

func _physics_process(delta: float) -> void:
	navigationAgent.target_position = player.global_position
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta


	var next_point = navigationAgent.get_next_path_position()
	var direction = global_position.direction_to(next_point).normalized()
	look_at(Vector3(navigationAgent.target_position.x, global_position.y, navigationAgent.target_position.z), Vector3.UP)
	velocity = SPEED * direction
	


	move_and_slide()


func damage(dmg):
	health -= dmg
	
	if health <= 0:
		queue_free()
		player.apply_experience(expAmount)
		enemyDeath.emit()
