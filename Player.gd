extends KinematicBody2D

const GRAVITY = 2000
const MOVE_SPEED = 500
const JUMP_VELOCITY = 650

onready var sprite = get_node("CorgiSprite")
onready var animations = get_node("AnimationPlayer")
onready var canon = get_node("CorgiSprite/CanonSprite")
onready var crosshair = get_node("CanvasLayer/Crosshair")
onready var shadow = get_node("CorgiSprite/Shadow")
onready var thought_bubble = get_node("CorgiSprite/ThoughtBubble")

var velocity = Vector2()
var grounded = true
var falling_through = false
var trying_jump = false
var air_jumps = 0
var is_flipping = false

var flip_angle = 0
var aim_angle = 0
var old_anim = ""
var thought_shown_time = 0

func _fixed_process(delta):
	if Input.is_action_pressed("right"):
		velocity.x = MOVE_SPEED
		flip_corgi(true)
		set_animation("walk")
	elif Input.is_action_pressed("left"):
		velocity.x = -MOVE_SPEED
		flip_corgi(false)
		set_animation("walk")
	else:
		velocity.x = 0
		set_animation("idle")
	
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
		set_layer_mask_bit(1, false)
		falling_through = true
	elif !Input.is_action_pressed("drop_down") and falling_through:
		set_layer_mask_bit(1, true)
		falling_through = false
	
	var motion = velocity*delta
	var did_move = motion.length_squared() > 0
	
	motion = move(motion)
	
	if is_colliding():
		var n = get_collision_normal()
		grounded = n.dot(Vector2(0, 1)) < -0.99
		if grounded:
			air_jumps = 0
			trying_jump = false
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		if motion.length_squared() > 0.01:
			move(motion)
	else:
		grounded = false
	
	if did_move:
		rotate_canon()

func show_thought():
	thought_shown_time = 5
	thought_bubble.set_hidden(false)

func _process(delta):
	thought_shown_time -= delta
	if thought_shown_time >= 0:
		thought_shown_time -= delta
	else:
		thought_bubble.set_hidden(true)
	
	if is_flipping:
		show_thought()
		set_animation("flip")
		flip_angle += PI*3.3*delta
		if flip_angle >= PI*2:
			flip_angle = 0
			is_flipping = false
			sprite.set_rot(0)
			return
		
		if sprite.is_flipped_h():
			sprite.set_rot(flip_angle)
			canon.set_rot(aim_angle-flip_angle)
			thought_bubble.set_rot(-flip_angle)
		else:
			sprite.set_rot(-flip_angle)
			canon.set_rot(aim_angle+flip_angle)
			thought_bubble.set_rot(flip_angle)
	else:
		set_animation("")

func rotate_canon():
	var rot = canon.get_global_pos().angle_to_point(canon.get_global_mouse_pos() - Vector2(0, -34))
	var fire_pos = canon.get_node("FirePos").get_pos()
	var sprite_flipped = sprite.is_flipped_h()
	if sprite_flipped:
		rot += PI/2
	else:
		rot -= PI/2
	if abs(rot) > PI/2:
		canon.set_flip_h(!sprite_flipped)
		fire_pos.x = abs(fire_pos.x)
		rot -= PI
	else:
		fire_pos.x = -abs(fire_pos.x)
		canon.set_flip_h(sprite_flipped)
	
	if sprite_flipped:
		fire_pos.x *= -1
	
	canon.get_node("FirePos").set_pos(fire_pos)
	aim_angle = rot
	canon.set_rot(rot)

func flip_corgi(flip_direction):
	if flip_direction != sprite.is_flipped_h():
		sprite.set_flip_h(flip_direction)
		var old_pos = canon.get_pos()
		#if (flip_direction and old_pos.x > 0) or (!flip_direction and old_pos.x < 0):
		old_pos.x *= -1
		canon.set_pos(old_pos)
		var bubble_offset = thought_bubble.get_offset()
		bubble_offset.x *= -1
		thought_bubble.set_offset(bubble_offset)
		thought_bubble.set_flip_h(flip_direction)
		thought_bubble.get_child(0).set_offset(bubble_offset)
		rotate_canon()

func _input(event):
	if event.is_action_pressed("fire"):
		canon.emit_signal("fire")
	elif event.type == InputEvent.MOUSE_MOTION:
		var viewport_rect = get_viewport_rect().end
		if event.pos.x > viewport_rect.x:
			event.pos.x = viewport_rect.x
		elif event.pos.x < 0:
			event.pos.x = 0
		if event.pos.y > viewport_rect.y:
			event.pos.y = viewport_rect.y
		elif event.pos.y < 0:
			event.pos.y = 0
		get_viewport().warp_mouse(event.pos)
		crosshair.set_pos(event.pos)
		rotate_canon()

func set_animation(animation):
	var shadow_visible = false
	if is_flipping:
		old_anim = animation
		sprite.set_animation("flip")
	elif !grounded:
		if velocity.y <= 0:
			sprite.set_animation("jump")
		else:
			sprite.set_animation("fall")
	elif animation == "":
		shadow_visible = true
		sprite.set_animation(old_anim)
	else:
		shadow_visible = true
		old_anim = animation
		sprite.set_animation(animation)
	shadow.set_hidden(!shadow_visible)

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	set_process(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
