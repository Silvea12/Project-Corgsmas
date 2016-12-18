extends AnimatedSprite

var has_played = false

func _process(delta):
	if get_frame() == 3:
		queue_free()

func _ready():
	set_process(true)
	set_frame(0)
	play()