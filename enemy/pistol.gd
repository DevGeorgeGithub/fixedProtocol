extends Spatial

export var damage = 5
############################ # через global add scene, $timer
var bullet_scene = preload("res://scene/weapons/Bullet_Scene.tscn")
var timer = 1
func _process(delta):
	if owner.angry:
		self.visible = true
		if timer <= 0:
			fire_bullet()
			timer = 1
		else:
			timer -= delta

func fire_bullet():
	var clone = bullet_scene.instance()
	var scene_root = get_tree().root.get_children()[0]
	scene_root.add_child(clone)

	clone.global_transform = $gun_barrel.global_transform
	clone.scale = Vector3(8, 8, 8)
	clone.BULLET_DAMAGE = damage
	clone.BULLET_SPEED = 60
	owner.player.health -= damage
############################
