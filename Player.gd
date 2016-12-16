extends KinematicBody2D

const GRAVITY = 50
const MOVE_SPEED = 5
const JUMP_VELOCITY = 15

onready var sprite = get_node("Sprite")

var velocity = Vector2()
var grounded = true
var falling_through = false

func _fixed_process(delta):
	if Input.is_action_pressed("right"):
		velocity.x = MOVE_SPEED
		sprite.set_flip_h(true)
	elif Input.is_action_pressed("left"):
		velocity.x = -MOVE_SPEED
		sprite.set_flip_h(false)
	else:
		velocity.x = 0
	
	if Input.is_action_pressed("jump") and grounded:
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
		movement = n.slide(movement)
		velocity = n.slide(velocity)
		move(movement)
	else:
		grounded = false

func _ready():
	set_fixed_process(true)
