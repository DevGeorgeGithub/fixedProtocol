extends Control

var start_menu
var options_menu

export (String, FILE) var mainArea

func _ready():
	start_menu = $Start_Menu
	options_menu = $Options_Menu

	$Start_Menu/Title_Label/Button_Start.connect("pressed", self, "start_menu_button_pressed", ["start"])
	$Start_Menu/Title_Label/Button_Options.connect("pressed", self, "start_menu_button_pressed", ["options"])
	$Start_Menu/Title_Label/Button_Quit.connect("pressed", self, "start_menu_button_pressed", ["quit"])

	$Options_Menu/Button_Back.connect("pressed", self, "options_menu_button_pressed", ["back"])
	$Options_Menu/Button_Fullscreen.connect("pressed", self, "options_menu_button_pressed", ["fullscreen"])

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	var globals = get_node("/root/Globals")
	$Options_Menu/HSlider_Mouse_Sensitivity.value = globals.mouse_sensitivity

func start_menu_button_pressed(button_name):
	if button_name == "start":
		start_menu.visible = false
		set_mouse_and_joypad_sensitivity()
		get_node("/root/Globals").load_new_scene(mainArea)
	elif button_name == "options":
		options_menu.visible = true
		start_menu.visible = false
	elif button_name == "quit":
		get_tree().quit()

func options_menu_button_pressed(button_name):
	if button_name == "back":
		start_menu.visible = true
		options_menu.visible = false
	elif button_name == "fullscreen":
		OS.window_fullscreen = !OS.window_fullscreen


func set_mouse_and_joypad_sensitivity():
	var globals = get_node("/root/Globals")
	globals.mouse_sensitivity = $Options_Menu/HSlider_Mouse_Sensitivity.value
