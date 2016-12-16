extends KinematicBody2D

const GRAVITY = 50
const MOVE_SPEED = 5
const JUMP_VELOCITY = 15

onready var sprite = get_node("CorgiSprite")
onready var animations = get_node("AnimationPlayer")

var velocity = Vector2()
var grounded = true
var falling_through = false
var trying_jump = false
var air_jumps = 0

func _fixed_process(delta):
	if Input.is_action_pressed("right"):
		velocity.x = MOVE_SPEED
		sprite.set_flip_h(true)
	elif Input.is_action_pressed("left"):
		velocity.x = -MOVE_SPEED
		sprite.set_flip_h(false)
	else:
		velocity.x = 0
	
	var jumping = false
	if Input.is_action_pressed("jump") and !trying_jump:
		trying_jump = true
		jumping = true
	elif !Input.is_action_pressed("jump") and trying_jump:
		trying_jump = false
	
	if jumping and (grounded or air_jumps < 1):
		if !grounded:
			air_jumps += 1
		
		if air_jumps == 1:
			if sprite.is_flipped_h():
				animations.play_backwards("Flip")
			else:
				animations.play("Flip")
		velocity.y = -JUMP_VELOCITY
	
	velocity.y += GRAVITY*delta
	
	if Input.is_action_pressed("drop_down") and !falling_through:
		falling_through = true
		var platforms = get_tree().get_nodes_in_group("platforms")
		for i in platforms:
			i.add_collision_exception_with(self)
	elif !Input.is_action_pressed("drop_down") and falling_through:
		falling_through = false
		var platforms = get_tree().get_nodes_in_group("platforms")
		for i in platforms:
			i.remove_collision_exception_with(self)
	
	var movement = move(velocity)
	
	
	if is_colliding():
		var n = get_collision_normal()
		grounded = n.dot(Vector2(0, 1)) < -0.99
		if grounded:
			air_jumps = 0
			trying_jump = false
		movement = n.slide(movement)
		velocity = n.slide(velocity)
		move(movement)
	else:
		grounded = false

func _ready():
	set_fixed_process(true)
