extends Area

export(int) var ammo = 10

func _on_Ammo_body_entered(body):
	if body.name == "Player":
		body.weapon_manager.add_ammo(ammo)
		var result = body.get_node("CamRoot/GrenadeThrowPos").add_grenade()
		if result:
			respawn_ammo()

func respawn_ammo():
	$Shape_Kit.disabled = true
	$Ammo_Kit.visible = false
	yield(get_tree().create_timer(5), "timeout")
	$Shape_Kit.disabled = false
	$Ammo_Kit.visible = true



