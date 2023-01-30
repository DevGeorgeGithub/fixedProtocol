extends Spatial

class_name Weapon

var damage
var ammo_in_weapon
var spare_ammo
var ammo_in_bag

func _init(_damage, _ammo_in_weapon, _spare_ammo, _ammo_in_bag):
    damage = _damage
    ammo_in_weapon = _ammo_in_weapon
    spare_ammo = _spare_ammo
    ammo_in_bag = _ammo_in_bag
func _ready():
    pass
func reload_weapon():
    var ammo_needed = ammo_in_bag - ammo_in_weapon
    if spare_ammo >= ammo_needed:
        spare_ammo -= ammo_needed
        ammo_in_weapon = ammo_in_bag
    else:
        ammo_in_weapon += spare_ammo
        spare_ammo = 0
func reset_weapon(_ammo_in_weapon, _spare_ammo):
    ammo_in_weapon = _ammo_in_weapon
    spare_ammo = _spare_ammo

