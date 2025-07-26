extends Area3D

@export var enemy_scene: PackedScene
@export var number_to_spawn: int = 1
@export var spawn_area: CollisionShape3D
@export var waves: int
@export var timer: Timer
@export var timeBetweenWaves: float
@export var enemiesScenes: Array[PackedScene]
var enemyCount: int
var maxEnemies: int
var enemiesKilled: int

var enemiesSpawned = []

var waveCount = 0

func _ready() -> void:
	timer.wait_time = timeBetweenWaves
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	maxEnemies = number_to_spawn * waves

func spawn_enemies():
	var shape = spawn_area.shape as BoxShape3D
	var extents = shape.extents
	enemyCount += number_to_spawn
	print(enemyCount)

	for i in number_to_spawn:
		var random_offset = Vector3(
			randf_range(-extents.x, extents.x),
			randf_range(1, 1),
			randf_range(-extents.z, extents.z)
		)

		var spawn_position = global_transform.origin + random_offset

		for j in enemiesScenes.size():
			var enemy = enemiesScenes[j].instantiate()
			get_tree().current_scene.add_child(enemy)
			enemiesSpawned.append(enemy)
			enemy.connect("enemyDeath", _on_enemy_death)
			enemy.global_transform.origin = spawn_position


func _on_timer_timeout() -> void:
	waveCount += 1

	if waveCount >= waves:
		timer.stop()

	spawn_enemies()

func _on_enemy_death():
	enemiesKilled += 1
	if enemiesKilled >= maxEnemies:
		pass
