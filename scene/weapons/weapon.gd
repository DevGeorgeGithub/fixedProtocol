extends Spatial

class_name Weapon

var weapon_manager = null
var player = null
var ray = null

var hitbox = null

var is_equipped = false

export var weapon_name = "Weapon"

func equip():
	pass

func unequip():
	pass
func is_equip_finished():
	return false

func is_unequip_finished():
	return true

func update_ammo(action = "Refresh"):
	
	var weapon_data = {
		"Name" : weapon_name
	}
	weapon_manager.update_hud(weapon_data)