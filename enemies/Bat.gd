extends KinematicBody2D

signal hurt

const MAX_SPEED = 150
const ACCELERATION = 30
const APPROACH_DIST = 75

onready var player = get_tree().get_nodes_in_group("player")[0]
onready var sprite = get_node("AnimatedSprite")

var velocity = Vector2()
var spin_direction = false
var swooping = false
var time_swoop = 0

func _hurt(hit_pos, is_enemy):
	if !is_enemy:
		queue_free()

func _fixed_process(delta):
	time_swoop += delta
	var angle = get_angle_to(player.get_global_pos())
	var speed_multiplier = 1
	
	if time_swoop > 4:
		time_swoop = 0
		swooping = true
		sprite.set_animation("attack")
		sprite.set_rot(angle+PI/2)
	if swooping:
		if time_swoop < 0.2:
			speed_multiplier = 0
			velocity = Vector2()
		elif time_swoop > 2:
			time_swoop = 0
			swooping = false
			sprite.set_animation("fly")
			sprite.set_rot(0)
		else:
			speed_multiplier = 1.5
	if !swooping:
		if player.get_global_pos().distance_to(get_global_pos()) < APPROACH_DIST:
			if cos(angle) <= 0.2:
				spin_direction = sin(angle) <= 0.1
			
			if spin_direction:
				angle -= PI/2
			else:
				angle += PI/2
		
		#print(sin(angle))
	
	var new_dir = Vector2(0,1).rotated(angle)
	velocity += new_dir*ACCELERATION*speed_multiplier
	if velocity.length() > MAX_SPEED and !swooping:
		velocity = velocity.normalized() * MAX_SPEED
	
	var motion = velocity*delta
	
	motion = move(motion)
	
	if is_colliding():
		swooping = false
		sprite.set_animation("fly")
		sprite.set_rot(0)
		time_swoop = 0
		var n = get_collision_normal()
		get_collider().emit_signal("hurt", get_collision_pos(), true)
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		if motion.length_squared() > 0.01:
			move(motion)

func _ready():
	set_fixed_process(true)
	connect("hurt", self, "_hurt")