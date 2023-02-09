extends Area

var Position: Vector3
var Impact = 1000

onready var _Particles = $Particles

# Called when the node enters the scene tree for the first time.
func _ready():
	_Particles.emitting = true



func _on_Timer_timeout():
	queue_free()


func _on_Explosion_body_entered(body):
	Position = get_global_transform().origin
	#############
	if body.is_in_group("Weapon_Reactive"):
		body.HitSuccessful(Position, Impact)
#############
