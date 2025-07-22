extends Node3D

@export var weaponPoints: Node3D
@export var detectionArea: Area3D

var target_enemy = null

func _ready() -> void:
	pass



func _physics_process(delta: float) -> void:
	detect_enemy()
	if target_enemy != null:
		for point in weaponPoints.get_children():
			point.look_at(target_enemy.global_position)
			
			


func detect_enemy():
	var bodiesInArea = detectionArea.get_overlapping_bodies()
	for entity in bodiesInArea:
		if entity.is_in_group("Enemy"):
			target_enemy = bodiesInArea.front()
		
