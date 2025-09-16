extends Node

signal enemy_defeated
signal player_died
signal game_won

var enemies_defeated: int = 0
var max_enemies: int = 5
var game_active: bool = false

func _ready():
	# Add to game_manager group
	add_to_group("game_manager")
	# Auto-start the game when the level loads
	start_game()

func start_game():
	game_active = true
	enemies_defeated = 0
	print("Game started!")

func on_enemy_defeated():
	if not game_active:
		return
		
	enemies_defeated += 1
	print("Enemies defeated: ", enemies_defeated, "/", max_enemies)
	
	# Update UI counter
	var counter = get_tree().get_first_node_in_group("ui_counter")
	if counter:
		counter.text = "Enemies Defeated: " + str(enemies_defeated) + "/" + str(max_enemies)
	
	if enemies_defeated >= max_enemies:
		on_game_won()
	else:
		emit_signal("enemy_defeated")

func on_player_died():
	if not game_active:
		return
		
	game_active = false
	print("Player died - Game Over!")
	emit_signal("player_died")
	# Wait a moment then switch to death screen
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://death_screen.tscn")

func on_game_won():
	game_active = false
	print("Game won!")
	emit_signal("game_won")
	# Wait a moment then switch to win screen
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://win_screen.tscn")

func restart_game():
	get_tree().change_scene_to_file("res://level.tscn")

func go_to_menu():
	get_tree().change_scene_to_file("res://start_screen.tscn")
