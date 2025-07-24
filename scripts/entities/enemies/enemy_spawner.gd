extends Area3D

@export var enemy_scene: PackedScene
@export var number_to_spawn: int = 1
@export var spawn_area: CollisionShape3D
@export var waves: int
@export var timer: Timer
@export var timeBetweenWaves: float



var waveCount = 0

func _ready() -> void:
	timer.wait_time = timeBetweenWaves
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _physics_process(delta: float) -> void:
	if waveCount >= waves:
		timer.stop()

func spawn_enemies():
	var shape = spawn_area.shape as BoxShape3D
	var extents = shape.extents

	for i in number_to_spawn:
		var random_offset = Vector3(
			randf_range(-extents.x, extents.x),
			randf_range(1, 1),
			randf_range(-extents.z, extents.z)
		)

		var spawn_position = global_transform.origin + random_offset

		var enemy = enemy_scene.instantiate()
		get_tree().current_scene.add_child(enemy)
		enemy.global_transform.origin = spawn_position


func _on_timer_timeout() -> void:
	waveCount += 1
	spawn_enemies()
