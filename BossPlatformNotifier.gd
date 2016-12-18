extends Area2D

onready var boss = get_tree().get_nodes_in_group("boss")[0]

var timer = 0
var stomped = false

func _body_enter(body):
	if body.is_in_group("player"):
		set_fixed_process(true)
		stomped = false
		timer = 0

func _body_exit(body):
	if body.is_in_group("player"):
		set_fixed_process(false)

func _fixed_process(delta):
	timer += delta
	
	if timer >= 0.5 and !stomped:
		stomped = true
		boss.emit_signal("player_on_platform", get_child(0))

func _ready():
	connect("body_enter", self, "_body_enter")
	connect("body_exit", self, "_body_exit")
