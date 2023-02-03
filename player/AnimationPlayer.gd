extends AnimationPlayer

var callback_function

func _ready():
	pass

func animation_callback():
    callback_function.call_func()

