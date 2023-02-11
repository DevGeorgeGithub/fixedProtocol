extends Weapon
class_name Armed

export(PackedScene) var weapon_pickup

var animation_player

var is_firing = false
var is_reloading = false

export var ammo_in_mag = 15
export var extra_ammo = 30
onready var mag_size = ammo_in_mag
onready var _extra_ammo = extra_ammo

export var damage = 10
export var fire_rate = 1.0

export var equip_pos = Vector3.ZERO

export(NodePath) var muzzle_flash_path
onready var muzzle_flash = get_node(muzzle_flash_path)

export var equip_speed = 1.0
export var unequip_speed = 1.0
export var reload_speed = 1.0

var sway_pivot = null

export var ads_pos = Vector3.ZERO
var ads_speed = 10
var is_ads = false

signal SprayCalc
signal ResetSpray
export var SprayVectors: PoolVector2Array
var spray_high:float = 0
var ModTracker: float = 0
export(int, 1,10,.5) var SpayScale
var NewSpray: Vector3 = Vector3.ZERO
var BulletsFired = 1

onready var bullet_hole = preload("res://models/weapons/bulletHole.tscn")

func _ready():
	set_as_toplevel(true)
	call_deferred("create_sway_pivot")

func fire():
	if !is_reloading and ammo_in_mag > 0:
		if !is_firing:
				is_firing = true
				animation_player.get_animation("Fire")
				if weapon_name == 'Rifle':
					animation_player.get_animation("Fire").loop = true
				animation_player.play("Fire", -1.0, fire_rate)
		return
	elif is_firing:
		fire_stop()

func fire_stop():
	is_firing = false
	animation_player.get_animation("Fire").loop = false
	
	reset_spray()
	
func fire_bullet():  
	muzzle_flash.emitting = true
	update_ammo("consume")
	
	ray.force_raycast_update()
	
	if ray.is_colliding():
		var body = ray.get_collider()

		bullet_hit(body)

		if body.is_in_group("Enemies"):
			body.health -= damage		
	spraying()

	bullet_hole()

func reset_spray():
	emit_signal("ResetSpray")
	ray.ResetSpray()
	if weapon_name == 'Rifle':
		NewSpray = Vector3.ZERO
		BulletsFired = 1
		spray_high = 0
	if weapon_name == 'Pistol':
		var BulletStopTimer = $Timer
		BulletStopTimer.start()

func spraying():
	var _spray = Spray()
	NewSpray = NewSpray +_spray
	emit_signal("SprayCalc", _spray)
	ray.SprayCalc(_spray)

	BulletsFired += 1

func bullet_hole():
	var new_bullet_hole = bullet_hole.instance()
	ray.force_raycast_update()
	if ray.is_colliding():
		ray.get_collider().add_child(new_bullet_hole)
		new_bullet_hole.global_transform.origin = ray.get_collision_point()
		var dir_up = Vector3(0,1,0)
		var dir_down = Vector3(0,-1,0)

		if ray.get_collision_normal() == dir_up or ray.get_collision_normal() == dir_down:
			new_bullet_hole.look_at(ray.get_collision_point() + ray.get_collision_normal(), Vector3.RIGHT)
		else:
			new_bullet_hole.look_at(ray.get_collision_point() + ray.get_collision_normal(), Vector3.DOWN)

func knife_hit():
	var bodies = hitbox.get_overlapping_bodies()
	for body in bodies:
		if body == player:
			continue

		bullet_hit(body)

func bullet_hit(body):
	if body.has_method("bullet_hit"):
		body.bullet_hit(damage, ray.global_transform)

func reload():
	if ammo_in_mag < mag_size and extra_ammo > 0 or ammo_in_mag == 0 and extra_ammo > 0:
		is_firing = false
		animation_player.play("Reload", -1.0, reload_speed)
		is_reloading = true

func equip():
	weapon_manager.hideWeapon()
	animation_player.play("Equip", -1.0, equip_speed)
	is_reloading = false

func unequip():
	animation_player.play("Unequip", -1.0, unequip_speed)

func is_equip_finished():
	if is_equipped:
		return true
	else:
		return false

func is_unequip_finished():
	if is_equipped:
		return false
	else:
		return true

func show_weapon():
	visible = true

func hide_weapon():
	visible = false

func on_animation_finish(anim_name):
	match anim_name:
		"Unequip":
			is_equipped = false
		"Equip":
			is_equipped = true
		"Reload":
			is_reloading = false
			update_ammo("reload")

func update_ammo(action = "Refresh", additional_ammo = 0):
	
	match action:
		"consume":
			ammo_in_mag -= 1
		
		"reload":
			var ammo_needed = mag_size - ammo_in_mag
			
			if extra_ammo > ammo_needed:
				ammo_in_mag = mag_size
				extra_ammo -= ammo_needed
			else:
				ammo_in_mag += extra_ammo
				extra_ammo = 0
		
		"add":
			extra_ammo += additional_ammo
	
	
	var weapon_data = {
		"Name" : weapon_name,
		"Ammo" : str(ammo_in_mag),
		"ExtraAmmo" : str(extra_ammo)
	}
	
	weapon_manager.update_hud(weapon_data)

func drop_weapon():
	var pickup = Global.instantiate_node(weapon_pickup, global_transform.origin - player.global_transform.basis.z.normalized())
	pickup.ammo_in_mag = ammo_in_mag
	pickup.extra_ammo = extra_ammo
	pickup.mag_size = mag_size
	queue_free()

func create_sway_pivot():
	sway_pivot = Spatial.new()
	get_parent().add_child(sway_pivot)
	sway_pivot.transform.origin = equip_pos
	sway_pivot.name = weapon_name + "_Sway"

func sway(delta):
	global_transform.origin = sway_pivot.global_transform.origin
	
	var self_quat = global_transform.basis.get_rotation_quat()
	var pivot_quat = sway_pivot.global_transform.basis.get_rotation_quat()
	
	var new_quat = Quat()
	
	if is_ads == false:
		new_quat = self_quat.slerp(pivot_quat, 25 * delta)
	else:
		new_quat = pivot_quat
	
	global_transform.basis = Basis(new_quat)

func aim_down_sights(value, delta):
	is_ads = value
	
	if is_ads == false and player.camera.fov == 70:
		return
	
	if is_ads:
		sway_pivot.transform.origin = sway_pivot.transform.origin.linear_interpolate(ads_pos, ads_speed * delta)
		player.camera.fov = lerp(player.camera.fov, 50, ads_speed * delta)
	else:
		sway_pivot.transform.origin = sway_pivot.transform.origin.linear_interpolate(equip_pos, ads_speed * delta)
		player.camera.fov = lerp(player.camera.fov, 70, ads_speed * delta)

func _exit_tree():
	sway_pivot.queue_free()

func reset_weapon():
	ammo_in_mag = mag_size
	extra_ammo = _extra_ammo

func Spray(Mod: float = 0.0):
	Mod = round(Mod)
	ModTracker += Mod
	spray_high = sqrt(pow(SpayScale + Mod, 2) + pow(spray_high, 2))
	var spray_bullet_coordinate = BulletsFired % SprayVectors.size()
	var Spray = Vector3(spray_high * SprayVectors[spray_bullet_coordinate].x, spray_high * SprayVectors[spray_bullet_coordinate].y, 0)
	if Mod == 0 && ModTracker > 1 or BulletsFired  == 1:
		spray_high = 0
		ModTracker = 0
	return Spray

func _on_Timer_timeout():
	BulletsFired = 1
