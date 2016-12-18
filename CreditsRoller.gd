extends Node

var credits_scene = preload("res://Credits.tscn")

func roll_credits():
	get_node("/root/Main").queue_free()
	get_parent().add_child(credits_scene.instance())