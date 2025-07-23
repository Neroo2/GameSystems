@tool
extends Area3D


const ENEMY = preload("res://scenes/entities/enemies/enemy.tscn")
@export var collisionShape : CollisionShape3D



func spawn_enemy():

	var spawn_pos = $".".global_position
	var enemy_instance = ENEMY.instantiate()

	get_tree().current_scene.add_child(enemy_instance)
	enemy_instance.global_position = spawn_pos



func _on_timer_timeout() -> void:
	spawn_enemy()
