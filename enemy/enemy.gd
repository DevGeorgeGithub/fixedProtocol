extends KinematicBody

export var speed = 10

onready var agent = $NavigationAgent

onready var player = $"../../Player"

onready var map_floor = $"../CSGCombiner/CSGBox"

var space_state

var angry = false
var scared = false

var left_edge = false

var health = 100

var calm = true

func _ready():	
	space_state = get_world().direct_space_state
 
	agent.set_target_location(Vector3(0,0,self.transform.origin.z))


func _physics_process(delta):

	if agent.is_target_reachable() and !agent.is_target_reached():
		var next = agent.get_next_location()
		var velocity = (next - transform.origin).normalized()
		move_and_slide(velocity * speed, Vector3.UP)

		# fire_trigger()
		run_away()

		look_at(Vector3(agent.get_final_location()), Vector3.UP)

	if health <= 0:
		queue_free()

func run_away():
	if Input.is_action_pressed("fire") or scared or is_player_take_weapon():
		scared = true
		calm = false

		if player.transform.origin.z < agent.get_target_location().z:
			agent.set_target_location(Vector3(map_floor.get_width() / 2, 0, map_floor.get_depth() / 2))
		else:	
			agent.set_target_location(Vector3(map_floor.get_width() / 2, 0, -map_floor.get_depth() / 2))


func fire_trigger():
	if Input.is_action_pressed("fire") or angry or is_player_take_weapon():
		angry = true
		calm = false

		if player.transform.origin:
			var result = space_state.intersect_ray(global_transform.origin, player.transform.origin)
			if result.collider.is_in_group("Player"):
				agent.set_target_location(player.transform.origin)
				look_at(player.transform.origin, Vector3.UP)
				$MeshInstance.get_surface_material(0).set_albedo(Color(1, 0, 0))
			else:
				calm = true
				angry = false
				$Pistol.visible = false
				$MeshInstance.get_surface_material(0).set_albedo(Color(0, 1, 0))	

func is_player_take_weapon():
	var player_weapon_manager = player.get_node("CamRoot/Weapons")
	for i in player_weapon_manager.weapons:
		if i != "Empty":
			if player_weapon_manager.weapons[i].visible:
				return true		

func _on_NavigationAgent_target_reached():
	if calm:
		if left_edge:
			agent.set_target_location(Vector3(map_floor.get_width() / 2,0,23))
			left_edge = false
		else:
			agent.set_target_location(Vector3(-map_floor.get_width() / 2,0,23))
			left_edge = true

