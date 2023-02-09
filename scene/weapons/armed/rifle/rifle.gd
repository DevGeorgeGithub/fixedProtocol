extends Armed

func _ready():
	animation_player = $AnimationPlayer
	if animation_player != null:
		animation_player.connect("animation_finished", self, "on_animation_finish")


func on_animation_finish(anim_name):
	.on_animation_finish(anim_name)





