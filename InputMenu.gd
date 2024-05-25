extends Control

var is_paused = false: set = set_is_paused

func pause_menu():
	self.is_paused = !is_paused

func set_is_paused(value):
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused


func _on_Done_pressed():
	self.is_paused = false


func _on_Cancel_pressed():
	self.is_paused = false
