# extends Spatial
extends Armed

func _ready():
	animation_player = $AnimationPlayer
	if animation_player != null:
		animation_player.connect("animation_finished", self, "on_animation_finish")


func on_animation_finish(anim_name):
	.on_animation_finish(anim_name)
# var Weapon = preload("res://scene/weapons/weapon.gd")
# var weapon
# var defaultAmmo_in_weapon = 50
# var defaultSpare_ammo = 100
# var player_node = null

# func _init():
# 	weapon = Weapon.new(4,50,100,50)


# func fire_weapon():
# 	var ray = $Ray_Cast
# 	ray.force_raycast_update()
# 	if ray.is_colliding():
# 		var body = ray.get_collider()
# 		if body == player_node:
# 			pass
# 		elif body.has_method("bullet_hit"):
# 			body.bullet_hit(weapon.damage, ray.global_transform)
# 	weapon.ammo_in_weapon -= 1




