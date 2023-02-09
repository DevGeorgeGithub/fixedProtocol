extends RayCast

onready var AimCast = $"."

func ResetSpray():
	AimCast.set_cast_to(Vector3(0,0,-100))

func SprayCalc(_spray: Vector3):
	var CurrentAim = AimCast.get_cast_to()
	var NewAim = CurrentAim + _spray
	AimCast.set_cast_to(NewAim)

