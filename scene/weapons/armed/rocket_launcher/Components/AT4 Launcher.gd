# extends Spatial
extends Armed

onready var RocketPoint = $RocketPoint
onready var AnimPlay = $AnimationPlayer
onready var _Camera = get_viewport().get_camera()
onready var _Viewport = get_viewport().get_size()

export var RocketSpeed: int = 80

var Rocket = preload("res://scene/weapons/armed/rocket_launcher/Components/Rocket.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player = $AnimationPlayer
	if animation_player != null:
		animation_player.connect("animation_finished", self, "on_animation_finish")

func _PrimaryFire():
	var Target = GetCameraCollision()
	var RocketDirection = (Target-RocketPoint.global_transform.origin).normalized()
	SpawnRocket(RocketDirection)

func GetCameraCollision()->Vector3:
	var RayOrgin = _Camera.project_ray_origin(_Viewport/2)
	var RayEnd = (RayOrgin+_Camera.project_ray_normal(_Viewport/2)*500)
	
	var Intersection = get_world().direct_space_state.intersect_ray(RayOrgin, RayEnd)
	
	if not Intersection.empty():
		var ColPoint = Intersection.position
		return ColPoint
	else:
		return RayEnd

func SpawnRocket(Dir:Vector3):
	var W = get_tree().get_root()
	var R = Rocket.instance()
	W.add_child(R)
	R.set_mode(RigidBody.MODE_RIGID)
	R.set_global_transform(RocketPoint.get_global_transform())
	R.set_linear_velocity(Dir*RocketSpeed)
	

func _PrimaryFireReleased():
	pass

func on_animation_finish(anim_name):
	.on_animation_finish(anim_name)

