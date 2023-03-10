extends Control


var weapon_ui
var health_ui
var grenade_ui
# var display_ui
var slot_ui

func _enter_tree():
	weapon_ui = $Background/WeaponUI
	health_ui = $Background/HealthUI
	grenade_ui = $Background/GrenadeUI
	# display_ui = $Background/Display/TextureRect
	slot_ui = $Background/Display/WeaponSlot


func _ready():
	hide_interaction_prompt()

func _process(delta):
	health_ui.text = "Health: " + str(owner.health)
	grenade_ui.text = "Grenades: " + str(get_parent().get_node("CamRoot/GrenadeThrowPos").grenade_amounts)
	
func update_weapon_ui(weapon_data, weapon_slot):
	slot_ui.text = weapon_slot
	# display_ui.texture = weapon_data["Image"]

	if weapon_data["Name"] == "Unarmed" or weapon_data["Name"] == "Knife":
		weapon_ui.text = weapon_data["Name"]
		return
	
	weapon_ui.text = weapon_data["Name"] + ": " + weapon_data["Ammo"] + "/" + weapon_data["ExtraAmmo"]

# Show/Hide interaction prompt
func show_interaction_prompt(description = "Interact"):
	$InteractionPrompt.visible = true
	$InteractionPrompt/Description.text = description
	$Crosshair.visible = false

func hide_interaction_prompt():
	$InteractionPrompt.visible = false
	$Crosshair.visible = true




