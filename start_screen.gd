extends Control

func _ready():
	print("======================================")
	print("START SCREEN LOADED SUCCESSFULLY!")
	print("======================================")
	$VBoxContainer/StartButton.pressed.connect(_on_start_button_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_button_pressed)
	# Make sure the screen is visible
	show()
	modulate = Color(1, 1, 1, 1)

func _on_start_button_pressed():
	print("Starting game...")
	get_tree().change_scene_to_file("res://level.tscn")

func _on_quit_button_pressed():
	print("Quitting game...")
	get_tree().quit()
