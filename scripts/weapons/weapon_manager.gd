extends Node3D

@export var weaponPoints: Node3D
@export var detectionArea: Area3D

@export var weapon: Weapon


var target_enemy = null

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var enemies_in_area = get_enemies_in_area()
	
	for point in weaponPoints.get_children():
		var closest_enemy = get_closest_enemy_to_point(point, enemies_in_area)
		if closest_enemy:
			point.look_at(closest_enemy.global_position)
			
			

func add_weapon_to_player(weapon: Weapon):

	for point in weaponPoints.get_children():
		if point.get_child_count() == 0:
			var weaponScene = weapon.weaponScene.instantiate()
			point.add_child(weaponScene)
			return

func get_enemies_in_area() -> Array:
	var enemies: Array = []
	for entity in detectionArea.get_overlapping_bodies():
		if entity.is_in_group("Enemy"):
			enemies.append(entity)
	return enemies


func get_closest_enemy_to_point(point: Node3D, enemies: Array) -> Node3D:
	var closest_enemy = null
	var closest_distance = INF

	for enemy in enemies:
		var distance = point.global_position.distance_to(enemy.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy
	
	return closest_enemy

		
