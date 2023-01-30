extends Spatial

const DAMAGE = 40
var ammo_in_weapon = 0
var player_node = null

func _ready():
	pass

func fire_weapon():
	var area = $Area
	var bodies = area.get_overlapping_bodies()

	for body in bodies:
		if body == player_node:
			continue

		if body.has_method("bullet_hit"):
			body.bullet_hit(DAMAGE, area.global_transform)

