extends Node

var mouse_sensitivity = 0.08
var joypad_sensitivity = 2
var canvas_layer = null
const MAIN_MENU_PATH = "res://menu/Main_Menu.tscn"
const POPUP_SCENE = preload("res://menu/Pause_Popup.tscn")
var popup = null

func instantiate_node(packed_scene, pos = null, parent = null):
	var clone = packed_scene.instance()
	
	var root = get_tree().root
	if parent == null:
		parent = root.get_child(root.get_child_count()-1)
	
	parent.add_child(clone)
	
	if pos != null:
		clone.global_transform.origin = pos
	
	return clone

func _ready():
	canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)

func load_new_scene(new_scene_path):
	get_tree().change_scene(new_scene_path)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit() # Быстрый выход
		if popup == null:
			popup = POPUP_SCENE.instance()

			popup.get_node("Button_quit").connect("pressed", self, "popup_quit")
			# popup.connect("popup_hide", self, "popup_closed")
			# popup.get_node("Button_resume").connect("pressed", self, "popup_closed")

			canvas_layer.add_child(popup)
			popup.popup_centered()

			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

			get_tree().paused = true

# func popup_closed():
# 	get_tree().paused = false

# 	if popup != null:
# 		popup.queue_free()
# 		popup = null
  

func popup_quit():
	get_tree().paused = false

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if popup != null:
		popup.queue_free()
		popup = null
		
	load_new_scene(MAIN_MENU_PATH)

func get_respawn_position():
	return Vector3(0, 0, 0)

