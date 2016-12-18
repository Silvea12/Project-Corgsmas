extends KinematicBody2D

signal hurt
signal player_on_platform

onready var sprite = get_node("AnimatedSprite")
onready var player = get_tree().get_nodes_in_group("player")[0]

var velocity = Vector2()

const GRAVITY = 1500
const WALK_SPEED = 100

const ACTION_WALK = 0
const ACTION_ATTACK = 1
const ACTION_SMALL_STOMP = 2
const ACTION_JUMP_STOMP = 3

var anim_timer = 0
var anim_length = 3
var caused_damage = false
var curr_anim = ACTION_WALK
var health = 20


func _hurt():
	health -= 1
	if health == 0:
		queue_free()

func _player_on_platform():
	apply_animation(ACTION_JUMP_STOMP)

func apply_animation(anim):
	curr_anim = anim
	var new_anim = ""
	if anim == ACTION_WALK:
		new_anim = "walk"
	elif anim == ACTION_ATTACK:
		new_anim = "attack"
		sprite.set_flip_h(get_global_pos().x - player.get_global_pos().x <= 0)
	elif anim == ACTION_SMALL_STOMP:
		new_anim = "small_stomp"
		sprite.set_flip_h(get_global_pos().x - player.get_global_pos().x <= 0)
	elif anim == ACTION_JUMP_STOMP:
		new_anim = "jump_stomp"
	
	anim_length = sprite.get_sprite_frames().get_frame_count(new_anim)
	sprite.set_animation(new_anim)
	anim_timer = 0
	caused_damage = false

func _fixed_process(delta):
	anim_timer += delta
	
	var player_distance = (get_global_pos() - player.get_global_pos()).length()
	
	var facing_right = sprite.is_flipped_h()
	
	if anim_timer >= rand_range(2,4):
		apply_animation(ACTION_ATTACK)
	
	if curr_anim == ACTION_WALK:
		if player_distance < 60:
			if player.get("grounded"):
				apply_animation(ACTION_SMALL_STOMP)
			else:
				apply_animation(ACTION_ATTACK)
		elif facing_right:
			velocity.x = WALK_SPEED
		else:
			velocity.x = -WALK_SPEED
	else:
		velocity.x = 0
	
	velocity.y += GRAVITY*delta
	
	var motion = velocity*delta
	motion = move(motion)
	
	if is_colliding():
		var n = get_collision_normal()
		if get_collider().is_in_group("edge"):
			sprite.set_flip_h(!facing_right)
		#get_collider().emit_signal("hurt", get_collision_pos())
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		if motion.length_squared() > 0.01:
			move(motion)

func _process(delta):
	if curr_anim != ACTION_WALK:
		var curr_frame = sprite.get_frame()
		if curr_frame == anim_length - 1:
			apply_animation(ACTION_WALK)
		elif (curr_anim == ACTION_SMALL_STOMP or curr_anim == ACTION_ATTACK) and curr_frame == 2 && !caused_damage:
			caused_damage = true
			var knockback_dir = player.get_global_pos()
			if sprite.is_flipped_h():
				knockback_dir.x -= 1
			else:
				knockback_dir.x += 1
			player.emit_signal("hurt", knockback_dir)

func _ready():
	connect("hurt", self, "_hurt")
	connect("player_on_platform", self, "_player_on_platform")
	set_process(true)
	set_fixed_process(true)
