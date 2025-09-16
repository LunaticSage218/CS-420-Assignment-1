extends Control

func _ready():
	$VBoxContainer/PlayAgainButton.pressed.connect(_on_play_again_button_pressed)
	$VBoxContainer/MenuButton.pressed.connect(_on_menu_button_pressed)

func _on_play_again_button_pressed():
	print("Playing again...")
	get_tree().change_scene_to_file("res://level.tscn")

func _on_menu_button_pressed():
	print("Going to main menu...")
	get_tree().change_scene_to_file("res://start_screen.tscn")
