extends KinematicBody2D

signal hurt

const GRAVITY = 1500
const MOVE_SPEED = 200

onready var player = get_tree().get_nodes_in_group("player")[0]

var moving = true
var slow_moving = false
var move_switch_time = 0
var velocity = Vector2()

func _hurt():
	# Enable when we have death anim
	#get_node("CollisionShape2D").queue_free()
	queue_free()

func _fixed_process(delta):
	move_switch_time += delta
	
	if move_switch_time > 0.5:
		moving = randi() % 4 > 0
		slow_moving = randi() % 3 == 0
		move_switch_time = 0
	
	if moving:
		velocity.x = sign(player.get_global_pos().x - get_global_pos().x)*MOVE_SPEED
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