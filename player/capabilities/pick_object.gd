extends Position3D

var picked_object
var weapon_manager

func _process(delta):
	pick_object()
	
func pick_object():
	if Input.is_action_just_pressed("fire") and weapon_manager.current_weapon.name == "Unarmed":
		if picked_object == null:
			var _raycast = get_parent().get_node("RayCast")
			_raycast.cast_to = Vector3(0,0,-3)
			_raycast.force_raycast_update()
			_raycast.cast_to = Vector3(0,0,-100)
			var collider = _raycast.get_collider()
			if collider != null and collider is RigidBody:
				picked_object = collider

		elif picked_object != null:
			var knockback = picked_object.translation - owner.translation
			picked_object.apply_central_impulse(knockback * 15)
			picked_object = null
	
	if picked_object != null:
		var HoldPosition = self
		var pull_power = 24
		var picked_object_pos = picked_object.global_transform.origin
		var HoldPosition_pos = HoldPosition.global_transform.origin
		picked_object.set_linear_velocity((HoldPosition_pos - picked_object_pos)*pull_power)
	
		if weapon_manager.current_weapon.name != "Unarmed":
			picked_object = null	
