extends CharacterBody2D

var speed := 800
var jump_velocity := -600
var gravity := 1500
var attack_range := 325.0  # How close enemy needs to be to hit

# Screen bounds
var screen_width := 1800
var screen_height := 800

# Reference to the AnimatedSprite2D (adjust path if needed)
var sprite

func _ready():
	sprite = $AnimatedSprite2D  # Initialize sprite reference
	# Connect hurt box collision
	var hurtbox = $HurtBox
	if hurtbox:
		hurtbox.body_entered.connect(_on_hurt_box_body_entered)
		print("Player HurtBox connected successfully")
		print("Player collision_layer: ", collision_layer)
	else:
		print("ERROR: HurtBox not found!")

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# Horizontal movement
	velocity.x = 0
	if Input.is_action_pressed("right"):
		velocity.x = speed
		sprite.flip_h = false
		if is_on_floor():
			sprite.play("walk")
	elif Input.is_action_pressed("left"):
		velocity.x = -speed
		sprite.flip_h = true
		if is_on_floor():
			sprite.play("walk")
	elif Input.is_action_pressed("fight_left"):
		sprite.flip_h = false
		sprite.play("fight")
		if Input.is_action_just_pressed("fight_left"):
			_check_for_attack()
	elif Input.is_action_pressed("fight_right"):
		sprite.flip_h = true
		sprite.play("fight")
		if Input.is_action_just_pressed("fight_right"):
			_check_for_attack()
	else:
		if is_on_floor():
			sprite.play("idle")

	# Jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		sprite.play("jump")

	# Move the player
	move_and_slide()

	# Keep inside screen bounds
	position.x = clamp(position.x, 100, screen_width + 50)
	position.y = clamp(position.y, 50, screen_height)

func _check_for_attack():
	# Find all enemies in the scene
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	for enemy in enemies:
		# Check if enemy is within attack range
		var distance = global_position.distance_to(enemy.global_position)
		if distance <= attack_range:
			# Check if attacking in the right direction
			var enemy_direction = enemy.global_position.x - global_position.x
			var attacking_left = Input.is_action_just_pressed("fight_left")
			var attacking_right = Input.is_action_just_pressed("fight_right")
			
			# Only hit if attacking in correct direction
			if (attacking_left and enemy_direction < 0) or (attacking_right and enemy_direction > 0):
				print("Hit enemy in correct direction!")
				enemy.defeat()
				break  # Only hit one enemy per attack
			else:
				print("Missed! Wrong attack direction")

func _on_hurt_box_body_entered(body):
	print("HurtBox collision detected with: ", body.name, " Groups: ", body.get_groups())
	if body.is_in_group("enemies"):
		print("Player hit by enemy - Game Over!")
		# Get the game manager and trigger death
		var game_manager = get_tree().get_first_node_in_group("game_manager")
		if game_manager:
			game_manager.on_player_died()
		else:
			print("ERROR: Game manager not found!")
	else:
		print("Non-enemy collision detected")
