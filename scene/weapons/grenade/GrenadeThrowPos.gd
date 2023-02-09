extends Spatial

var grenade_amounts = 5
var max_grenades = 10

var grenade_scene = preload("res://scene/weapons/grenade/Grenade.tscn")
const GRENADE_THROW_FORCE = 70

func _process(delta):
	throwGrenade()

func throwGrenade():
	grenade_amounts = clamp(grenade_amounts, 0, max_grenades)

	if Input.is_action_just_pressed("fire_grenade"):
		if grenade_amounts > 0:
			grenade_amounts -= 1
			var grenade_clone
			grenade_clone = grenade_scene.instance()
			get_tree().root.add_child(grenade_clone)
			grenade_clone.global_transform = self.global_transform
			grenade_clone.apply_impulse(Vector3(0, 0, 0), grenade_clone.global_transform.basis.z * GRENADE_THROW_FORCE)    

func add_grenade():
	if grenade_amounts == max_grenades:
		return false
	grenade_amounts += 2
	return true
