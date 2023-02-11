extends Spatial

export var damage = 5
var bullet_scene = preload("res://scene/weapons/Bullet_Scene.tscn")
var TIME_PERIOD = 1
var time = 0

func _process(delta):
	if owner.angry:
		self.visible = true
		time += delta
		if time > TIME_PERIOD:
			fire_bullet()
			time = 0

func fire_bullet():
	var clone = bullet_scene.instance()
	var scene_root = get_tree().root.get_children()[0]
	scene_root.add_child(clone)

	clone.global_transform = $gun_barrel.global_transform
	clone.scale = Vector3(8, 8, 8)
	clone.BULLET_DAMAGE = damage
	clone.BULLET_SPEED = 60
	owner.player.health -= damage

