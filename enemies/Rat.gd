extends KinematicBody2D

signal hurt

const GRAVITY = 1500
const MOVE_SPEED = 150

onready var player = get_tree().get_nodes_in_group("player")[0]
onready var sprite = get_node("AnimatedSprite")

var moving = true
var slow_moving = false
var move_switch_time = 0
var velocity = Vector2()

func _hurt():
	# Enable when we have death anim
	#get_node("CollisionShape2D").queue_free()
	queue_free()

func _fixed_process(delta):
	var distance = player.get_global_pos().distance_to(get_global_pos())
	if distance > 250:
		return
	
	move_switch_time += delta
	
	if move_switch_time > 0.5:
		moving = randi() % 4 > 0
		if !moving:
			sprite.stop()
		else:
			sprite.play()
		slow_moving = randi() % 3 == 0
		if slow_moving:
			sprite.get_sprite_frames().set_animation_speed("default", 8)
		else:
			sprite.get_sprite_frames().set_animation_speed("default", 12)
		move_switch_time = 0
	
	if moving:
		velocity.x = sign(player.get_global_pos().x - get_global_pos().x)*MOVE_SPEED
		sprite.set_flip_h(velocity.x > 0)
		if slow_moving:
			velocity.x /= 1.5
	else:
		velocity.x = 0
	
	velocity.y += GRAVITY*delta
	
	var motion = velocity*delta
	
	motion = move(motion)
	
	if is_colliding():
		var n = get_collision_normal()
		get_collider().emit_signal("hurt", get_collision_pos())
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		if motion.length_squared() > 0.01:
			move(motion)

func _ready():
	randomize()
	set_fixed_process(true)
	connect("hurt", self, "_hurt")