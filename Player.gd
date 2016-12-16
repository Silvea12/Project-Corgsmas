extends KinematicBody2D

const GRAVITY = 50
const MOVE_SPEED = 5
const JUMP_VELOCITY = 15

onready var sprite = get_node("CorgiSprite")
onready var animations = get_node("AnimationPlayer")
onready var canon = get_node("CorgiSprite/CanonSprite")

var velocity = Vector2()
var grounded = true
var falling_through = false
var trying_jump = false
var air_jumps = 0
var is_flipping = false

var flip_angle = 0
var aim_angle = 0

func _fixed_process(delta):
	if Input.is_action_pressed("right"):
		velocity.x = MOVE_SPEED
		sprite.set_flip_h(true)
		canon.set_scale(Vector2(-1, 1))
		var old_pos = canon.get_pos()
		if old_pos.x > 0:
			old_pos.x *= -1
		canon.set_pos(old_pos)
	elif Input.is_action_pressed("left"):
		velocity.x = -MOVE_SPEED
		canon.set_scale(Vector2(1, 1))
		var old_pos = canon.get_pos()
		if old_pos.x < 0:
			old_pos.x *= -1
		canon.set_pos(old_pos)
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
			is_flipping = true
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

func _process(delta):
	if is_flipping:
		flip_angle += PI*3.3*delta
		if flip_angle >= PI*2:
			flip_angle = 0
			is_flipping = false
			sprite.set_rot(0)
			return
		
		if sprite.is_flipped_h():
			sprite.set_rot(flip_angle)
			canon.set_rot(aim_angle-flip_angle)
		else:
			sprite.set_rot(-flip_angle)
			canon.set_rot(aim_angle+flip_angle)

func _input(event):
	if event.is_action_pressed("fire"):
		canon.emit_signal("fire")
	elif event.type == InputEvent.MOUSE_MOTION:
		aim_angle += event.relative_x/100.0
		if abs(aim_angle) > PI*1/3:
			aim_angle = PI*1/3*sign(aim_angle)
		canon.set_rot(aim_angle)

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	set_process(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
