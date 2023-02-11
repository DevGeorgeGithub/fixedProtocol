extends Area

var force = 1000
var damage = 100

func _on_Timer_timeout():
	queue_free()

func _on_Explosion_body_entered(body):
	for body in self.get_overlapping_bodies():
		if body is RigidBody:
			body.add_central_force((body.global_transform.origin - global_transform.origin).normalized() * force)
		
		if body.is_in_group("Enemies"):
			body.health -= damage	

