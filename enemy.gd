extends CharacterBody2D

signal enemy_defeated

@export var speed: float = 200.0
@export var gravity: float = 1500.0  # Same as player gravity
var target: Node2D = null

func _ready():
	# By default, move toward the player (if exists)
	target = get_tree().get_first_node_in_group("player")
	print("Enemy spawned at: ", global_position)
	print("Enemy collision_layer: ", collision_layer)
	
	# Connect AttackBox collision
	var attackbox = $AttackBox
	if attackbox:
		attackbox.body_entered.connect(_on_attack_box_body_entered)
		print("Enemy AttackBox connected successfully")
		print("AttackBox collision_mask: ", attackbox.collision_mask)
		print("AttackBox monitoring: ", attackbox.monitoring)
	else:
		print("ERROR: Enemy AttackBox not found!")
	
	if target:
		print("Enemy targeting player at: ", target.global_position)
	else:
		print("ERROR: Player not found by enemy!")

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
	
	# Move toward target horizontally
	if target:
		var direction_to_target = target.global_position.x - global_position.x
		var distance_to_target = abs(direction_to_target)
		
		# Debug output every 60 frames (1 second)
		if Engine.get_process_frames() % 60 == 0:
			print("Enemy at: ", global_position, " Player at: ", target.global_position, " Distance: ", distance_to_target)
			# Check if we're overlapping
			var attackbox = $AttackBox
			if attackbox:
				var overlapping = attackbox.get_overlapping_bodies() 
				print("Overlapping bodies: ", overlapping.size())
				for body in overlapping:
					print("  - ", body.name, " Groups: ", body.get_groups())
		
		if distance_to_target > 10:  # Only move if not very close
			velocity.x = sign(direction_to_target) * speed
		else:
			velocity.x = 0
	else:
		velocity.x = 0
	
	move_and_slide()

func defeat():
	print("Enemy defeated!")
	emit_signal("enemy_defeated")
	# Notify game manager
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		game_manager.on_enemy_defeated()
	queue_free()  # Remove the enemy from the scene

func _on_attack_box_body_entered(body):
	print("\n======= ENEMY COLLISION DETECTED =======")
	print("Enemy AttackBox collision with: ", body.name, " Groups: ", body.get_groups())
	print("Enemy position: ", global_position)
	print("Body position: ", body.global_position)
	print("========================================\n")
	if body.is_in_group("player"):
		print("Enemy hit player - Game Over!")
		# Get the game manager and trigger death
		var game_manager = get_tree().get_first_node_in_group("game_manager")
		if game_manager:
			game_manager.on_player_died()
		else:
			print("ERROR: Game manager not found by enemy!")
			# Fallback - directly change scene
			get_tree().change_scene_to_file("res://death_screen.tscn")
	else:
		print("Collision detected but not with player!")
