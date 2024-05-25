extends Node2D

var a = "Graph#1"
var b = "Graph"

func _ready():
	if b in a:
		print(true)
