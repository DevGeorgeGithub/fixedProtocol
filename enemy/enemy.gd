extends KinematicBody

export var speed = 10

onready var agent = $NavigationAgent

onready var player = $"../../Player"

var space_state

var angry = false

var left_edge = false

var health = 100

func _ready():
	space_state = get_world().direct_space_state
	agent.set_target_location(Vector3(0,0,0))

func _physics_process(delta):
	var next = agent.get_next_location()
	var velocity = (next - transform.origin).normalized()
	move_and_slide(velocity * speed, Vector3.UP)

	fire_trigger()

	if health <= 0:
		queue_free()

func fire_trigger():
	if Input.is_action_pressed("fire") or angry or is_player_take_weapon():
		angry = true
		
		if player.transform.origin:
			var result = space_state.intersect_ray(global_transform.origin, player.transform.origin)
			if result.collider.is_in_group("Player"):
				agent.set_target_location(player.transform.origin)
				look_at(player.transform.origin, Vector3.UP)
				$MeshInstance.get_surface_material(0).set_albedo(Color(1, 0, 0))
			else:
				$MeshInstance.get_surface_material(0).set_albedo(Color(0, 1, 0))	

func is_player_take_weapon():
	var player_weapon_manager = player.get_node("CamRoot/Weapons")
	for i in player_weapon_manager.weapons:
		if player_weapon_manager.weapons[i].visible:
			return true		

func _on_NavigationAgent_target_reached():
	if left_edge:
		agent.set_target_location(Vector3(50,0,23))
		left_edge = false
	else:
		agent.set_target_location(Vector3(-50,0,23))
		left_edge = true

