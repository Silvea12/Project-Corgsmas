extends KinematicBody2D

signal hurt
const DEATH_TIME = 1.3
var death_timer = 0
onready var player = get_tree().get_nodes_in_group("player")[0]

var velocity = Vector2()

func _hurt():
	# Enable when we have death anim
	#get_node("CollisionShape2D").queue_free()
	queue_free()

func _fixed_process(delta):
	var angle = get_angle_to(player.get_global_pos())
	var new_dir = Vector2(0,1).rotated(angle)
	velocity = new_dir
	
	move(velocity)

func _ready():
	set_fixed_process(true)
	connect("hurt", self, "_hurt")