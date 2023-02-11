extends RigidBody

var Explosion = preload("res://scene/weapons/armed/rocket_launcher/Components/Explosion.tscn")

func _on_Timer_timeout():
	var W = get_tree().get_root()
	var E = Explosion.instance()
	E.set_global_transform(get_global_transform())
	W.add_child(E)
	queue_free()

	