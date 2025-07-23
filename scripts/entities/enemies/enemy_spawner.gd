extends Area3D


const ENEMY = preload("res://scenes/entities/enemies/enemy.tscn")


func _physics_process(delta: float) -> void:
	print($CollisionShape3D.shape.extents)
	


func spawn_enemy():
	var box_shape = $CollisionShape3D.shape as BoxShape3D
	var extents = box_shape.extents

	var random_offset = Vector3(
		randf_range(-extents.x, extents.x),
		randf_range(-extents.y, extents.y),
		randf_range(-extents.z, extents.z)
	)

	var spawn_pos = global_transform.origin + random_offset
	var enemy_instance = ENEMY.instantiate()

	get_tree().current_scene.add_child(enemy_instance)
	enemy_instance.global_position = spawn_pos



func _on_timer_timeout() -> void:
	spawn_enemy()
