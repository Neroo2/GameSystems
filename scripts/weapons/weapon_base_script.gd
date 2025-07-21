extends Node
class_name BaseWeaponScript

@export_category("Weapon Info")
@export var weaponName: String
@export var weaponMaxCharge: int
@export var weaponDamage: int
@export var weaponRaycast: RayCast3D


@export_category("Weapon Animation")
@export var animationPlayer: AnimationPlayer
@export var shootAnimation: String


var vfx:Dictionary = {
	"enemy_damage":
		"res://scenes/particles/enemy_damage_vfx.tscn",
	"enemy_impact":
		"res://scenes/particles/enemy_impact_vfx.tscn",
		
}



func _physics_process(delta: float) -> void:
	if weaponRaycast.is_colliding() and !animationPlayer.is_playing():
		shoot()


func shoot():
	if weaponRaycast.is_colliding():
		var collider = weaponRaycast.get_collider()
		if collider.is_in_group("Enemy"):
			if !animationPlayer.is_playing():
				animationPlayer.play(shootAnimation)
				if collider.has_method("damage"):
					collider.damage(weaponDamage)
					create_vfx("enemy_damage")
					create_vfx("enemy_impact")
					
					
func create_vfx(vfx_name):
	if !vfx.has(vfx_name):
		return
		
	var timer: Timer =  Timer.new()
		
	var vfx_load = load(vfx[vfx_name])
	var vfx_instance: GPUParticles3D = vfx_load.instantiate()
		
	var colpoint = weaponRaycast.get_collision_point()
	var colnormal = weaponRaycast.get_collision_normal()


	get_tree().current_scene.add_child(vfx_instance)
	vfx_instance.global_position = colpoint
	
	get_tree().current_scene.add_child(timer)
	timer.wait_time = vfx_instance.lifetime
	timer.start()
	
		
	vfx_instance.look_at(colpoint + colnormal * 2, Vector3.UP)
	vfx_instance.look_at(colpoint + colnormal * 2, Vector3.RIGHT)
	vfx_instance.emitting = true

	await timer.timeout
	vfx_instance.queue_free()
	timer.queue_free()
