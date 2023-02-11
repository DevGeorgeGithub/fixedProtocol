extends Spatial

onready var weapon_manager = $Weapons
onready var SprayTween = get_parent().get_node("SprayTween")
onready var SprayResetTween = get_parent().get_node("SprayResetTween")

var SprayReset: bool = true
var SprayFactor = 0.001
var OriginalPoint: Vector3

func _ready():
	ConnectGunSignals()

func ConnectGunSignals():
	for w in weapon_manager.weapons:
		if is_instance_valid(weapon_manager.weapons[w]):
			if w != "Empty" and w != "Knife" and !weapon_manager.weapons[w].is_connected("SprayCalc", self,"MouseSpray"):
				weapon_manager.weapons[w].connect("SprayCalc", self,"MouseSpray")
				weapon_manager.weapons[w].connect("ResetSpray", self,"ResetMouseSpray")

func MouseSpray(Spray: Vector3):
	if SprayReset:
		OriginalPoint = self.get_rotation()
		SprayReset = false
	
	if SprayResetTween.is_active():
		SprayResetTween.stop_all()

	var CurrentPoint = self.get_rotation()
	var SprayVector = Vector3((Spray.y+rand_range(0.0,1))*SprayFactor,-Spray.x*SprayFactor,0.0)
	var NewPoint = CurrentPoint+SprayVector

	NewPoint.x = clamp(NewPoint.x,-1.5,0.5)
	SprayTween.interpolate_property(self,"rotation",CurrentPoint,NewPoint,.05,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	SprayTween.start()

func ResetMouseSpray():
	var CamPoint = self.get_rotation()
	SprayResetTween.interpolate_property(self,"rotation",CamPoint,OriginalPoint,.5,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	SprayResetTween.start()

func _on_SprayResetTween_tween_all_completed():
	SprayReset = true
