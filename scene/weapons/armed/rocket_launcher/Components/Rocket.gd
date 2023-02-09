extends RigidBody

var Explosion = preload("res://scene/weapons/armed/rocket_launcher/Components/Explosion.tscn")
onready var _Particles = $Particles

# Called when the node enters the scene tree for the first time.
func _ready():
	_Particles.emitting = true




func _on_Rocket_body_entered(body):
	var W = get_tree().get_root()
	var E = Explosion.instance()
	E.set_global_transform(get_global_transform())
	W.add_child(E)
	queue_free()
