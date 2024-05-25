extends Control

signal UpdateGraph(scrolltype, parameter, parameter2, value)

var inspectors = ["res://WelcomeScroll.tscn"]
var hierarchy = {
	"Welcome": ""
}

@onready var connections = {
	"New": get_node("MarginContainer/HBoxContainer/VBoxContainer/Button"),
	"Load": get_node("MarginContainer/HBoxContainer/VBoxContainer/Button2")
	}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
