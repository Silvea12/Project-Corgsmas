extends KinematicBody2D

signal hurt

const MAX_SPEED = 150
const ACCELERATION = 30
const APPROACH_DIST = 150
const DEAD_DIST = 10

onready var player = get_tree().get_nodes_in_group("player")[0]
onready var sprite = get_node("AnimatedSprite")

var velocity = Vector2()
var health = 2
var attacking = false
var attack_anim = false
var attack_timer = 0

func _hurt():
	health -= 1
	if health == 0:
		queue_free()
	# Enable when we have death anim
	#get_node("CollisionShape2D").queue_free()

func _fixed_process(delta):
	attack_timer += delta
	
	var angle = get_angle_to(player.get_global_pos())
	var left_side = sin(angle) > 0
	
	sprite.set_flip_h(left_side)
	
	if cos(angle) < 0.3:
		if left_side:
			angle += PI/2
		else:
			angle -= PI/2
	
	if attack_timer >= 4 and !attacking:
		attacking = true
		attack_timer = 0
	if attacking:
		print("WAT")
		if attack_timer >= 0.3:
			if !attack_anim:
				sprite.play("attack")
				print("FWAP")
			attack_anim = true
		else:
			sprite.stop()
		return
	
	
	var distance = (player.get_global_pos() - get_global_pos()).length()
	var slowing = false
	
	if abs(distance - APPROACH_DIST) < DEAD_DIST:
		slowing = true
	elif distance < APPROACH_DIST:
		angle += PI
	
	var new_dir = Vector2(0,1).rotated(angle)
	if slowing:
		if velocity.length() < ACCELERATION:
			velocity = Vector2()
		else:
			velocity -= velocity.normalized()*ACCELERATION
	else:
		velocity += new_dir*ACCELERATION
		if velocity.length() > MAX_SPEED:
			velocity = velocity.normalized() * MAX_SPEED
	
	var motion = velocity*delta
	
	motion = move(motion)
	
	if is_colliding():
		var n = get_collision_normal()
		#get_collider().emit_signal("hurt", get_collision_pos())
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		if motion.length_squared() > 0.01:
			move(motion)

func _process(delta):
	if attack_anim:
		if sprite.get_frame() == 4:
			attacking = false
			attack_anim = false
			sprite.set_animation("fly")
		pass

func _ready():
	set_process(true)
	set_fixed_process(true)
	connect("hurt", self, "_hurt")