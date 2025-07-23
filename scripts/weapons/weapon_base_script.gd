extends Node
class_name BaseWeaponScript

@export_category("Weapon Info")
@export var weaponName: String
@export var weaponMaxCharge: int
@export var weaponChargeRate: int
@export var weaponMaxDamage: int
@export var weaponMinDamage: int
@export var chargeWaitTime: float
@export var weaponRaycast: RayCast3D
@export var detectionArea: Area3D
@export var chargeTimer: Timer 
var canShoot: bool  = true
var currentCharge = 0
var wallCheck: Area3D
var currentDamage: int

@export_category("Weapon Animation")
@export var animationPlayer: AnimationPlayer
@export var shootAnimation: String


@export_category("Weapon Sounds")
@export var sound_manager: SoundManager 
@export var shoot_sound: String

var vfx:Dictionary = {
	"enemy_damage":
		"res://scenes/particles/enemy_damage_vfx.tscn",
		
}

func _ready():
	wallCheck = get_tree().current_scene.find_child("WallCheck")
	chargeTimer.wait_time = chargeWaitTime
	chargeTimer.one_shot = true

func _physics_process(delta: float) -> void:
	_verify_shoot_conditions()
	if canShoot:
		shoot()
		


func shoot():
	if weaponRaycast.is_colliding():
		var collider = weaponRaycast.get_collider()
		if !collider == null:
			if collider.is_in_group("Enemy"):
				if !animationPlayer.is_playing():
					sound_manager.play_audio(shoot_sound, 0.9, 1.2)
					animationPlayer.play(shootAnimation)
					if collider.has_method("damage"):
						currentDamage = randi_range(weaponMinDamage, weaponMaxDamage)
						collider.damage(currentDamage)
						currentCharge += weaponChargeRate
						_create_vfx("enemy_damage")

					
func _create_vfx(vfx_name):
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


func _verify_shoot_conditions():
	var collider = weaponRaycast.get_collider()
	
	if currentCharge >= weaponMaxCharge and not chargeTimer.is_stopped():
		return
	
	if wallCheck == null:
		return


	if currentCharge >= weaponMaxCharge:
		sound_manager.play_audio("steam_audio", 0.95, 1.1)
		canShoot = false
		chargeTimer.start()
		await chargeTimer.timeout
		currentCharge = 0
		canShoot = true
	
	elif currentCharge < weaponMaxCharge:
		if wallCheck.get_overlapping_bodies() != []:
			canShoot = false
		else:
			canShoot = true
		
	
