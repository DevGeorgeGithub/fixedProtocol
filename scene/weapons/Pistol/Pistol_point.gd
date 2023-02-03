extends Spatial

var Weapon = preload("res://scene/weapons/weapon.gd")
var weapon
var defaultAmmo_in_weapon = 10
var defaultSpare_ammo = 20
var bullet_scene = preload("res://scene/weapons/Bullet_Scene.tscn")

func _init():
	weapon = Weapon.new(15,10,20,10)

func fire_weapon():	
	var clone = bullet_scene.instance()
	var scene_root = get_tree().root.get_children()[0]
	scene_root.add_child(clone)
	
	clone.global_transform = self.global_transform
	clone.scale = Vector3(4, 4, 4)
	clone.BULLET_DAMAGE = weapon.damage
	weapon.ammo_in_weapon -= 1



