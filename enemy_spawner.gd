extends Node2D

@export var spawn_interval: float = 3.0
@export var enemy_scene: PackedScene = preload("res://enemy.tscn")

var screen_size: Vector2
var spawning: bool = false
var floor_y: float = 575.0  # Floor level based on scene setup
var current_enemy: Node2D = null  # Track the current enemy
var spawn_height_offset: float = 200.0  # How far above floor to spawn

func _ready():
	screen_size = get_viewport().get_visible_rect().size

func start_spawning():
	if spawning:
		return
	spawning = true
	_spawn_enemy()
	_schedule_next_spawn()

func _schedule_next_spawn():
	if spawning:
		get_tree().create_timer(spawn_interval).timeout.connect(_spawn_enemy)

func _spawn_enemy():
	if not spawning:
		return
	
	# Only spawn if no enemy currently exists
	if current_enemy != null and is_instance_valid(current_enemy):
		print("Enemy still alive, waiting before spawning next one")
		_schedule_next_spawn()
		return
	
	var enemy = enemy_scene.instantiate()
	var side = randi_range(0, 1)  # 0=left side, 1=right side
	var pos: Vector2
	
	match side:
		0: # Spawn on left side, above the floor
			pos = Vector2(50, floor_y - spawn_height_offset)
		1: # Spawn on right side, above the floor
			pos = Vector2(screen_size.x - 50, floor_y - spawn_height_offset)
	
	print("Spawning enemy at position: ", pos, " (will fall to floor)")

	enemy.global_position = pos
	current_enemy = enemy
	
	# Connect to enemy's defeated signal
	enemy.connect("enemy_defeated", _on_enemy_defeated)
	
	get_parent().add_child(enemy)
	
	# schedule the next spawn
	_schedule_next_spawn()

func _on_enemy_defeated():
	print("Enemy defeated, can spawn next one")
	current_enemy = null
