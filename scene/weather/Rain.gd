extends Particles

var current_weather = "rain"

func _on_Timer_timeout():
	if current_weather == "none":
		get_node("../Rain").set_emitting(true)
		current_weather = "rain"
		$Timer.wait_time = rand_range(10,25)
		$Timer.start()
	elif current_weather == "rain":
		get_node("../Rain").set_emitting(false)
		current_weather = "none"
		$Timer.wait_time = rand_range(10,15)
		$Timer.start()

func _process(delta):
	Global.weather = current_weather
