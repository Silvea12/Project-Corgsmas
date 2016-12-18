extends KinematicBody2D

signal hurt

const MAX_SPEED = 150
const ACCELERATION = 30
const APPROACH_DIST = 150
const DEAD_DIST = 10

onready var player = get_tree().get_nodes_in_group("player")[0]
onready var sprite = get_node("AnimatedSprite")
onready var fire_pos = get_node("FirePos")

var projectile = preload("res://enemies/GhostProjectile.tscn")

var velocity = Vector2()
var health = 2
var attacking = false
var attack_anim = false
var attack_timer = 0
var fired = false

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
	
	if left_side != sprite.is_flipped_h():
		var fpos = fire_pos.get_pos()
		fpos.x *= -1
		fire_pos.set_pos(fpos)
	
	sprite.set_flip_h(left_side)
	
	if attack_timer >= 4 and !attacking:
		attacking = true
		attack_timer = 0
	if attacking:
		if attack_timer >= 0.3:
			if !attack_anim:
				sprite.play("attack")
			attack_anim = true
		else:
			sprite.stop()
		return
	
	if cos(angle) < 0.3:
		if left_side:
			angle += PI/2
		else:
			angle -= PI/2
	
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
		if sprite.get_frame() == 3:
			if !fired:
				fired = true
				fire()
		elif sprite.get_frame() == 4:
			fired = false
			attacking = false
			attack_anim = false
			sprite.set_animation("fly")
		pass

func fire():
	var p = projectile.instance()
	p.set_global_pos(fire_pos.get_global_pos())
	p.add_collision_exception_with(self)
	p.rotate(get_angle_to(player.get_global_pos()) + PI/2)
	get_tree().get_root().add_child(p)

func _ready():
	set_process(true)
	set_fixed_process(true)
	connect("hurt", self, "_hurt")