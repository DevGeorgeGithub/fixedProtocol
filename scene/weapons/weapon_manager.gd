extends Spatial

export(NodePath) var ray_path

var all_weapons = {}

var weapons = {}

var current_weapon 
var current_weapon_slot = "Empty" 

var changing_weapon = false
var unequipped_weapon = false

var weapon_index = 0 

var hud

func _ready():
	hud = owner.get_node("HUD")
	get_node(ray_path).add_exception(owner)

	all_weapons = {
		"Unarmed" : preload("res://scene/weapons/unarmed/unarmed.tscn"),
		"Knife" : preload("res://scene/weapons/armed/knife/knife.tscn"),
		"Pistol" : preload("res://scene/weapons/armed/pistol/pistol.tscn"),
		"Rifle" : preload("res://scene/weapons/armed/rifle/rifle.tscn"),
		"AT4" : preload("res://scene/weapons/armed/rocket_launcher/Components/AT4 Launcher.tscn"),
	}
	
	weapons = {
		"Empty" : $Unarmed,
		"Knife" : $Knife,
		"Primary" : $Pistol,
		"Secondary" : $Rifle,
	}
	
	for w in weapons:
		if is_instance_valid(weapons[w]):
			weapon_setup(weapons[w])

	current_weapon = weapons["Empty"]
	change_weapon("Empty")
	
	set_process(false)

func weapon_setup(w):
	w.weapon_manager = self
	w.player = owner
	w.ray = get_node(ray_path)
	w.hitbox = get_parent().get_node("HeadBob/Camera/Hitbox")
	w.visible = false

func _process(delta):
	
	if unequipped_weapon == false:
		if current_weapon.is_unequip_finished() == false:
			return
		
		unequipped_weapon = true
		
		current_weapon = weapons[current_weapon_slot]
		current_weapon.equip()
	
	if current_weapon.is_equip_finished() == false:
		return
	
	changing_weapon = false
	set_process(false)

func change_weapon(new_weapon_slot):
	if new_weapon_slot == current_weapon_slot:
		current_weapon.update_ammo()
		return
	
	if is_instance_valid(weapons[new_weapon_slot]) == false:
		return

	current_weapon_slot = new_weapon_slot
	changing_weapon = true
	
	weapons[current_weapon_slot].update_ammo() 

	update_weapon_index()
	
	if is_instance_valid(current_weapon):
		unequipped_weapon = false
		current_weapon.unequip()
	
	set_process(true)

func update_weapon_index():
	match current_weapon_slot:
		"Empty":
			weapon_index = 0
		"Knife":
			weapon_index = 1
		"Primary":
			weapon_index = 2
		"Secondary":
			weapon_index = 3

func next_weapon():
	weapon_index += 1
	
	if weapon_index >= weapons.size():
		weapon_index = 0
	
	change_weapon(weapons.keys()[weapon_index])

func previous_weapon():
	weapon_index -= 1
	
	if weapon_index < 0:
		weapon_index = weapons.size() - 1
	
	change_weapon(weapons.keys()[weapon_index])

func hideWeapon():
	for w in weapons:
		if is_instance_valid(weapons[w]):
			weapon_setup(weapons[w])

func fire():
	if not changing_weapon:
		current_weapon.fire()

func fire_stop():
	current_weapon.fire_stop()

func reload():
	if not changing_weapon:
		current_weapon.reload()

func add_ammo(amount):
	if is_instance_valid(current_weapon) == false || current_weapon.name == "Unarmed" || current_weapon.name == "Knife":
		return false
	
	current_weapon.update_ammo("add", amount)
	return true

func add_weapon(weapon_data):
	
	if not weapon_data["Name"] in all_weapons:
		return

	if is_instance_valid(weapons["Primary"]) == false:
		
		var weapon = Global.instantiate_node(all_weapons[weapon_data["Name"]], Vector3.ZERO, self)
		
		weapon_setup(weapon)
		weapon.ammo_in_mag = weapon_data["Ammo"]
		weapon.extra_ammo = weapon_data["ExtraAmmo"]
		weapon.mag_size = weapon_data["MagSize"]
		weapon.transform.origin = weapon.equip_pos
		
		weapons["Primary"] = weapon
		change_weapon("Primary")
		
		return
	
	if is_instance_valid(weapons["Secondary"]) == false:
		
		var weapon = Global.instantiate_node(all_weapons[weapon_data["Name"]], Vector3.ZERO, self)
		
		weapon_setup(weapon)
		weapon.ammo_in_mag = weapon_data["Ammo"]
		weapon.extra_ammo = weapon_data["ExtraAmmo"]
		weapon.mag_size = weapon_data["MagSize"]
		weapon.transform.origin = weapon.equip_pos
		weapons["Secondary"] = weapon
		change_weapon("Secondary")
		
		return
	if is_instance_valid(weapons["Knife"]) == false:
		
		var weapon = Global.instantiate_node(all_weapons[weapon_data["Name"]], Vector3.ZERO, self)
		
		weapon_setup(weapon)
		weapon.ammo_in_mag = weapon_data["Ammo"]
		weapon.extra_ammo = weapon_data["ExtraAmmo"]
		weapon.mag_size = weapon_data["MagSize"]
		weapon.transform.origin = weapon.equip_pos
		
		weapons["Knife"] = weapon
		change_weapon("Knife")
		
		return

func drop_weapon():
	if current_weapon_slot != "Empty":
		current_weapon.drop_weapon()
		
		current_weapon_slot = "Empty"
		current_weapon = weapons["Empty"]
		
		current_weapon.update_ammo()

func switch_weapon(weapon_data):
	
	for i in weapons:
		if is_instance_valid(weapons[i]) == false:
			add_weapon(weapon_data)
			return
	
	if current_weapon.name == "Unarmed":
		weapons["Primary"].drop_weapon()
		yield(get_tree(), "idle_frame")
		add_weapon(weapon_data)
	
	elif current_weapon.weapon_name == weapon_data["Name"]:
		add_ammo(weapon_data["Ammo"] + weapon_data["ExtraAmmo"])
	
	else:
		drop_weapon()
		
		yield(get_tree(), "idle_frame")
		add_weapon(weapon_data)

func show_interaction_prompt(weapon_name):
	var desc = "Add Ammo" if current_weapon.weapon_name == weapon_name else "Equip"
	hud.show_interaction_prompt(desc)

func hide_interaction_prompt():
	hud.hide_interaction_prompt()

func process_weapon_pickup():
	var from = global_transform.origin
	var to = global_transform.origin - global_transform.basis.z.normalized() * 2.0
	var space_state = get_world().direct_space_state
	var collision = space_state.intersect_ray(from, to, [owner], 32768)
	
	if collision:
		var body = collision["collider"]
		
		if body.has_method("get_weapon_pickup_data"):
			var weapon_data = body.get_weapon_pickup_data()
			
			show_interaction_prompt(weapon_data["Name"])
			
			if Input.is_action_just_pressed("interact"):
				switch_weapon(weapon_data)
				body.queue_free()

				get_parent().ConnectGunSignals()
	else:
		hide_interaction_prompt()

func reset_weapons():
	for w in weapons:
		if is_instance_valid(weapons[w]) and w != "Empty":
			weapons[w].reset_weapon()

func update_hud(weapon_data):
	var weapon_slot = "1"
	
	match current_weapon_slot:
		"Empty":
			weapon_slot = "1"
		"Primary":
			weapon_slot = "2"
		"Secondary":
			weapon_slot = "3"
	if owner.has_node("HUD"):
		hud.update_weapon_ui(weapon_data, weapon_slot)
