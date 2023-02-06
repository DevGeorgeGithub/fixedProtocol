extends KinematicBody

export(NodePath) var camera_path
export(NodePath) var weapon_camera_path
export(NodePath) var weapon_manager_path

onready var camera = get_node(camera_path)
onready var weapon_camera = get_node(weapon_camera_path)
onready var weapon_manager = get_node(weapon_manager_path)

var MOUSE_SENSITIVITY = 0.05

var velocity = Vector3.ZERO
var current_vel = Vector3.ZERO
var dir = Vector3.ZERO
var snap = Vector3.ZERO

const SPEED = 15
const SPRINT_SPEED = 20
const ACCEL = 15.0

const GRAVITY = -40
const JUMP_SPEED = 18
var jump_counter = 0
const AIR_ACCEL = 9.0


var health = 100
const MAX_HEALTH = 150

var global

func _ready():
	camera.get_node("HoldPosition").weapon_manager = weapon_manager

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	global = get_node("/root/Global")
	MOUSE_SENSITIVITY = global.mouse_sensitivity
	global_transform.origin = global.get_respawn_position()

func _process(delta):
	process_weapons(delta)

func _physics_process(delta):
	process_input(delta)
	# process_respawn(delta)
	
func process_input(delta):

	dir = Vector3.ZERO
	
	if Input.is_action_pressed("forward"):
		dir -= global_transform.basis.z
	if Input.is_action_pressed("backward"):
		dir += global_transform.basis.z
	if Input.is_action_pressed("right"):
		dir += global_transform.basis.x
	if Input.is_action_pressed("left"):
		dir -= global_transform.basis.x

	dir = dir.normalized()
	
	if is_on_floor():
		jump_counter = 0
		velocity.y = -0.01
	else:
		velocity.y += GRAVITY * delta

	
	if Input.is_action_just_pressed("jump") and jump_counter < 1:
		jump_counter += 1
		velocity.y = JUMP_SPEED
		snap = Vector3.ZERO
	else:
		snap = Vector3.DOWN		
	var speed = 0
	
	if Input.is_action_pressed("sprint") and Input.is_action_pressed("ads") == false:
		speed = SPRINT_SPEED
	else:
		speed = SPEED

	var target_vel = dir * speed
	
	var accel = ACCEL if is_on_floor() else AIR_ACCEL
	
	current_vel = current_vel.linear_interpolate(target_vel, accel * delta)
	
	velocity.x = current_vel.x
	velocity.z = current_vel.z
	
	move_and_slide_with_snap(velocity, snap, Vector3.UP, true, 4, deg2rad(45))

	process_movement_effects(speed, delta)
	
	flash_light()

	camera.get_node("HoldPosition").pick_object()

	$CamRoot/GrenadeThrowPos.throwGrenade()

func process_movement_effects(speed, delta):
	
	if velocity.length() < 3.0 or is_on_floor() == false:
		$AnimationPlayer.play("HeadBob", 0.1, 0.2)
	elif velocity.length() <= SPEED:
		$AnimationPlayer.play("HeadBob", 0.1, 1.0)
	else:
		$AnimationPlayer.play("HeadBob", 0.1, 1.5)
	
	if speed == SPRINT_SPEED and velocity.length() > 3.0:
		weapon_camera.fov = lerp(weapon_camera.fov, 80, 10 * delta)
	else:
		weapon_camera.fov = lerp(weapon_camera.fov, 70, 10 * delta)

func flash_light():
	if Input.is_action_just_pressed("flashlight"):
		if $CamRoot/Flashlight.is_visible_in_tree():
			$CamRoot/Flashlight.hide()
		else:
			$CamRoot/Flashlight.show()

func process_weapons(delta):
	if Input.is_action_just_pressed("weapon0"):
		weapon_manager.change_weapon("Empty")
	if Input.is_action_just_pressed("weapon1"):
		weapon_manager.change_weapon("Knife")
	if Input.is_action_just_pressed("weapon2"):
		weapon_manager.change_weapon("Primary")
	if Input.is_action_just_pressed("weapon3"):
		weapon_manager.change_weapon("Secondary")

	if Input.is_action_pressed("fire"):
		weapon_manager.fire()
	if Input.is_action_just_released("fire"):
		weapon_manager.fire_stop()
	
	if weapon_manager.current_weapon.name != "Unarmed":
		if Input.is_action_just_pressed("reload") or weapon_manager.current_weapon.ammo_in_mag == 0:
			weapon_manager.reload()	

	if Input.is_action_just_pressed("drop"):
		weapon_manager.drop_weapon()
	
	weapon_manager.process_weapon_pickup()

	if weapon_manager.current_weapon.name != "Unarmed":
		weapon_manager.current_weapon.sway(delta)

	if Input.is_action_pressed("ads"):
		weapon_manager.current_weapon.aim_down_sights(true, delta)
	else:
		weapon_manager.current_weapon.aim_down_sights(false, delta)

func _input(event):

	if event is InputEventMouseMotion:
		$CamRoot.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		$CamRoot.rotation_degrees.x = clamp($CamRoot.rotation_degrees.x, -75, 75)
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				BUTTON_WHEEL_UP:
					weapon_manager.next_weapon()
				BUTTON_WHEEL_DOWN:
					weapon_manager.previous_weapon()		
	
# func add_health(additional_health):
# 	health += additional_health
# 	health = clamp(health, 0, MAX_HEALTH)

# func add_ammo(additional_ammo):
# 	if (current_weapon > weapons['knife']):
# 		weaponsPoint[current_weapon].weapon.spare_ammo += weaponsPoint[current_weapon].weapon.ammo_in_bag * additional_ammo

# func add_grenade(additional_grenade):
# 	grenade_amounts[current_grenade] += additional_grenade
# 	grenade_amounts[current_grenade] = clamp(grenade_amounts[current_grenade], 0, 4)

# func bullet_hit(damage, bullet_hit_pos):
# 	health -= damage

# func process_respawn(delta):
# 	if health <= 0:
# 		unequip()
# 		current_weapon = weapons['unarmed']

# 		if grabbed_object != null:
# 			grabbed_object.mode = RigidBody.MODE_RIGID
# 			grabbed_object.apply_impulse(Vector3(0, 0, 0), -camera.global_transform.basis.z.normalized() * OBJECT_THROW_FORCE / 2)

# 			grabbed_object.collision_layer = 1
# 			grabbed_object.collision_mask = 1

# 			grabbed_object = null
  
# 		global_transform.origin = globals.get_respawn_position()

# 		health = 100
# 		grenade_amounts = {"Grenade":2}

# 		if current_weapon != null:
# 			for _weapon in range(2, weapons.size()):
# 				weaponsPoint[_weapon].weapon.reset_weapon(weaponsPoint[_weapon].defaultAmmo_in_weapon, weaponsPoint[_weapon].defaultSpare_ammo)

