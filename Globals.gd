extends Node

var mouse_sensitivity = 0.08
var joypad_sensitivity = 2
var canvas_layer = null
const MAIN_MENU_PATH = "res://menu/Main_Menu.tscn"
const POPUP_SCENE = preload("res://menu/Pause_Popup.tscn")
var popup = null

var audio_clips = {
	"Pistol_shot": preload("res://sounds/shot.wav"),
	"reload": preload("res://sounds/reload.wav")
}

const SIMPLE_AUDIO_PLAYER_SCENE = preload("res://sounds/Simple_Audio_Player.tscn")
var created_audio = []

func _ready():
	canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)

func load_new_scene(new_scene_path):
	get_tree().change_scene(new_scene_path)
	for sound in created_audio:
		if (sound != null):
			sound.queue_free()
	created_audio.clear()

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit() # Быстрый выход
		if popup == null:
			popup = POPUP_SCENE.instance()

			popup.get_node("Button_quit").connect("pressed", self, "popup_quit")
			popup.connect("popup_hide", self, "popup_closed")
			popup.get_node("Button_resume").connect("pressed", self, "popup_closed")

			canvas_layer.add_child(popup)
			popup.popup_centered()

			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

			get_tree().paused = true

func popup_closed():
	get_tree().paused = false

	if popup != null:
		popup.queue_free()
		popup = null
  

func popup_quit():
	get_tree().paused = false

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if popup != null:
		popup.queue_free()
		popup = null
		
	load_new_scene(MAIN_MENU_PATH)

func get_respawn_position():
	return Vector3(0, 0, 0)

func play_sound(sound_name, loop_sound=false, sound_position=null):
	if audio_clips.has(sound_name):
		var new_audio = SIMPLE_AUDIO_PLAYER_SCENE.instance()
		new_audio.should_loop = loop_sound

		add_child(new_audio)
		created_audio.append(new_audio)

		new_audio.play_sound(audio_clips[sound_name], sound_position)
