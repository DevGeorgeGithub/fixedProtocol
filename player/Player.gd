extends KinematicBody

const GRAVITY = -40
var vel = Vector3()
const MAX_SPEED = 20
const JUMP_SPEED = 18
const ACCEL = 4.5

var health = 100
const MAX_HEALTH = 150

var dir = Vector3()

const DEACCEL= 16
const MAX_SLOPE_ANGLE = 40

var camera
var rotation_helper

var MOUSE_SENSITIVITY = 0.05

const MAX_SPRINT_SPEED = 30
const SPRINT_ACCEL = 18
var is_sprinting = false

var flashlight
var UI_status_label

var current_weapon = 0

var weapons = {"unarmed":0, "knife":1, "pistol":2, "rifle":3}
var weaponsPoint
onready var knife = $Rotation_Helper/Weapons/Knife
onready var pistol = $Rotation_Helper/Weapons/Pistol
onready var rifle = $Rotation_Helper/Weapons/Rifle
onready var Knife_point = $Rotation_Helper/Gun_Fire_Points/Knife_point
onready var Pistol_point = $Rotation_Helper/Gun_Fire_Points/Pistol_point
onready var Rifle_point = $Rotation_Helper/Gun_Fire_Points/Rifle_Point

var grenade_amounts = {"Grenade":2}
var current_grenade = "Grenade"
var grenade_scene = preload("res://scene/Utility/Grenade.tscn")
const GRENADE_THROW_FORCE = 50

var grabbed_object = null
const OBJECT_THROW_FORCE = 120
const OBJECT_GRAB_DISTANCE = 7
const OBJECT_GRAB_RAY_DISTANCE = 10

var globals

func _ready():
	camera = $Rotation_Helper/Camera
	rotation_helper = $Rotation_Helper
	flashlight = $Rotation_Helper/Flashlight
	UI_status_label = $Gun_Label
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	weaponsPoint = ["_", Knife_point, Pistol_point, Rifle_point]
	globals = get_node("/root/Globals")
	MOUSE_SENSITIVITY = globals.mouse_sensitivity
	global_transform.origin = globals.get_respawn_position()

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)
	if grabbed_object == null:
		weapon_select()
	process_UI(delta)
	process_respawn(delta)

func process_input(delta):
	dir = Vector3()
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1

	input_movement_vector = input_movement_vector.normalized()

	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x

	if is_on_floor():
		if Input.is_action_just_pressed("movement_jump"):
			vel.y = JUMP_SPEED

	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if Input.is_action_pressed("movement_sprint"):
		is_sprinting = true
	else:
		is_sprinting = false

	if Input.is_action_just_pressed("flashlight"):
		if flashlight.is_visible_in_tree():
			flashlight.hide()
		else:
			flashlight.show()	
	if Input.is_action_just_pressed("fire_grenade"):
		if grenade_amounts[current_grenade] > 0:
			grenade_amounts[current_grenade] -= 1
			var grenade_clone
			if current_grenade == "Grenade":
				grenade_clone = grenade_scene.instance()

			get_tree().root.add_child(grenade_clone)
			grenade_clone.global_transform = $Rotation_Helper/Grenade_Toss_Pos.global_transform
			grenade_clone.apply_impulse(Vector3(0, 0, 0), grenade_clone.global_transform.basis.z * GRENADE_THROW_FORCE)

	if Input.is_action_just_pressed("fire") and weapons['unarmed'] == current_weapon:
		if grabbed_object == null:
			var state = get_world().direct_space_state

			var center_position = get_viewport().size / 2
			var ray_from = camera.project_ray_origin(center_position)
			var ray_to = ray_from + camera.project_ray_normal(center_position) * OBJECT_GRAB_RAY_DISTANCE

			var ray_result = state.intersect_ray(ray_from, ray_to, [self, $Rotation_Helper/Gun_Fire_Points/Knife_point/Area])
			if !ray_result.empty():
				if ray_result["collider"] is RigidBody:
					grabbed_object = ray_result["collider"]
					grabbed_object.mode = RigidBody.MODE_STATIC

					grabbed_object.collision_layer = 0
					grabbed_object.collision_mask = 0

		else:
			grabbed_object.mode = RigidBody.MODE_RIGID

			grabbed_object.apply_impulse(Vector3(0, 0, 0), -camera.global_transform.basis.z.normalized() * OBJECT_THROW_FORCE)

			grabbed_object.collision_layer = 1
			grabbed_object.collision_mask = 1

			grabbed_object = null

	if grabbed_object != null:
		grabbed_object.global_transform.origin = camera.global_transform.origin + (-camera.global_transform.basis.z.normalized() * OBJECT_GRAB_DISTANCE)

func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()

	vel.y += delta * GRAVITY

	var hvel = vel
	hvel.y = 0

	var target = dir

	if is_sprinting:
		target *= MAX_SPRINT_SPEED
	else:
		target *= MAX_SPEED

	var accel
	if dir.dot(hvel) > 0:
		if is_sprinting:
			accel = SPRINT_ACCEL
		else:
			accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot

	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				if current_weapon < weapons.size() - 1:
					current_weapon += 1
				else:
					current_weapon = 0
			elif event.button_index == BUTTON_WHEEL_DOWN:
				if current_weapon > 0:
					current_weapon -= 1
				else:
					current_weapon = weapons.size() - 1

	fire()
	
	if current_weapon > weapons['knife']:
		if Input.is_action_just_pressed("reload") or weaponsPoint[current_weapon].weapon.ammo_in_weapon == 0:
			if weaponsPoint[current_weapon].weapon.spare_ammo > 0:
				weaponsPoint[current_weapon].weapon.reload_weapon()	
				globals.play_sound("reload", false, camera.global_transform.origin)	
		
func fire():

	if Input.is_action_just_pressed("fire") and current_weapon == weapons['knife']:
		Knife_point.fire_weapon()

	if Input.is_action_pressed("fire") and current_weapon == weapons['rifle']:
		if Rifle_point.weapon.ammo_in_weapon > 0:			
			Rifle_point.fire_weapon()
			globals.play_sound("Pistol_shot", false, $Rotation_Helper/Gun_Fire_Points/Rifle_Point/Ray_Cast.global_transform.origin)	

	if Input.is_action_just_pressed("fire") and current_weapon == weapons['pistol']:
		if Input.is_action_just_pressed("fire") and current_weapon == weapons['pistol']:
			if Pistol_point.weapon.ammo_in_weapon > 0:			
				Pistol_point.fire_weapon()	
				globals.play_sound("Pistol_shot", false, self.global_transform.origin)

func weapon_select():
	var countSwitchKeys = 4
	for key in countSwitchKeys:
		if Input.is_action_just_pressed("weapon" + str(key)):
			current_weapon = key

	weaponVisible([knife,pistol,rifle])

func weaponVisible(weapon):
	for weaponIndex in weapons.size() - 1:
		if current_weapon == weaponIndex + 1:
			weapon[weaponIndex].visible = true
		else:
			weapon[weaponIndex].visible = false

func process_UI(delta):
	if current_weapon <= weapons['knife']:
		UI_status_label.text = "HEALTH: " + str(health) + \
				"\n" + current_grenade + ": " + str(grenade_amounts[current_grenade])
	else:
		UI_status_label.text = "HEALTH: " + str(health) + \
		"\nAMMO: " + str(weaponsPoint[current_weapon].weapon.ammo_in_weapon) + "/" + str(weaponsPoint[current_weapon].weapon.spare_ammo) + \
				"\n" + current_grenade + ": " + str(grenade_amounts[current_grenade])

func create_sound(sound_name, position=null):
	globals.play_sound(sound_name, false, position)

func add_health(additional_health):
	health += additional_health
	health = clamp(health, 0, MAX_HEALTH)

func add_ammo(additional_ammo):
	if (current_weapon > weapons['knife']):
		weaponsPoint[current_weapon].weapon.spare_ammo += weaponsPoint[current_weapon].weapon.ammo_in_bag * additional_ammo

func add_grenade(additional_grenade):
	grenade_amounts[current_grenade] += additional_grenade
	grenade_amounts[current_grenade] = clamp(grenade_amounts[current_grenade], 0, 4)

func bullet_hit(damage, bullet_hit_pos):
	health -= damage

func process_respawn(delta):

	if health <= 0:
		current_weapon = weapons['unarmed']

		if grabbed_object != null:
			grabbed_object.mode = RigidBody.MODE_RIGID
			grabbed_object.apply_impulse(Vector3(0, 0, 0), -camera.global_transform.basis.z.normalized() * OBJECT_THROW_FORCE / 2)

			grabbed_object.collision_layer = 1
			grabbed_object.collision_mask = 1

			grabbed_object = null
  
		global_transform.origin = globals.get_respawn_position()

		health = 100
		grenade_amounts = {"Grenade":2}

		if current_weapon != null:
			for _weapon in range(2, weapons.size()):
				weaponsPoint[_weapon].weapon.reset_weapon(weaponsPoint[_weapon].defaultAmmo_in_weapon, weaponsPoint[_weapon].defaultSpare_ammo)
