extends Area

export(int) var health = 25

func _on_Health_body_entered(body):
	if body.name == "Player":
		var result = body.add_health(health)
		if result:
			respawn_health()

func respawn_health():
	$Shape_Kit.disabled = true
	$Health_Kit.visible = false
	yield(get_tree().create_timer(5), "timeout")
	$Shape_Kit.disabled = false
	$Health_Kit.visible = true
