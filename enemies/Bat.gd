extends KinematicBody2D

signal hurt
const MAX_SPEED = 150
const ACCELERATION = 30
onready var player = get_tree().get_nodes_in_group("player")[0]

var velocity = Vector2()

func _hurt():
	# Enable when we have death anim
	#get_node("CollisionShape2D").queue_free()
	queue_free()

func _fixed_process(delta):
	var angle = get_angle_to(player.get_global_pos())
	var new_dir = Vector2(0,1).rotated(angle)
	velocity += new_dir*ACCELERATION
	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED
	
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
	set_fixed_process(true)
	connect("hurt", self, "_hurt")