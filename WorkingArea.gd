extends Node2D

var spacebar_is_pressed = false # For camera movement - to pan the scene, hold space

const STATIONARY_CAMERA_ZOOM_AMOUNT = Vector2(0.2, 0.2)
const DYNAMIC_CAMERA_ZOOM_AMOUNT = STATIONARY_CAMERA_ZOOM_AMOUNT/4

var camera_reset_position = Vector2(0, 0) #Vector2(610, 324)

signal SelectedBoard(index)

@onready var zoom_label = $HUD/MarginContainer/VBoxContainer/PanelContainer/HBoxContainer/Label

var inspectors = [] # make sure to clear it every time!
var hierarchy : Dictionary = {}

var graphs_that_received_input = []
var selected_graph = null # if not needed in the future, delete

var graphs_by_priority = []
var mouse_input_activity : bool = false

func _ready():
	for child in $Graphs.get_children():
		print(child)
		for item in child.inspectors:
			if !inspectors.has(item):
				inspectors.append(item)
	
	for i in range(0, len($Graphs.get_children())):
		hierarchy[i] = []
		for item in $Graphs.get_child(i).inspectors:
			if item != "res://GraphScroll.tscn":
				hierarchy[i].append(Globals.convert_scroll_scene[item])
	
	
	connect_graph_boards($Graphs.get_children())
	
	set_labels()
	_on_reset_pressed()
	
	$Graphs/Graph2.position = Vector2(0, 0)

func _process(delta):
	set_camera_pan()
	
	if mouse_input_activity:
		var highest_priority_graph = null
		for graph in graphs_that_received_input:
			if highest_priority_graph != null:
				if graphs_by_priority.find(graph) > graphs_by_priority.find(highest_priority_graph):
					highest_priority_graph = graph
			else:
				highest_priority_graph = graph
		
		
		graphs_by_priority.erase(highest_priority_graph)
		graphs_by_priority.append(highest_priority_graph)
		
		selected_graph = highest_priority_graph
		for graph in graphs_that_received_input:
			if str(graph) != str(selected_graph):
				$Graphs.get_child(graph).select_board(false)
		
		for i in range(0, len(graphs_by_priority)):
			$Graphs.get_child(graphs_by_priority[i]).z_index = i
		
		SelectedBoard.emit(selected_graph)
		mouse_input_activity = false


### MANAGING CHILD GRAPHS ###

func connect_graph_boards(nodes: Array):
	for node in nodes:
		node.connect("BoardSelect", Callable(self, "set_selected_board"))

func _on_graphs_child_entered_tree(node):
	connect_graph_boards([node])
	graphs_by_priority.append(node.get_index())

func _on_graphs_child_exiting_tree(node):
	graphs_by_priority.erase(node.get_index())

func set_selected_board(index):
	graphs_that_received_input.append(index)
	mouse_input_activity = true


### INPUT-BASED FUNCTIONS ###
func set_camera_pan():
	if Input.is_action_pressed("spacebar"):
		spacebar_is_pressed = true
	else:
		spacebar_is_pressed = false

func camera_pan(movement):
	$Camera2D.position -= movement / $Camera2D.zoom
	set_labels()

func stationary_camera_zoom(zoom_amount):
	$Camera2D.zoom += zoom_amount
	
	set_labels()

func dynamic_camera_zoom(zoom_amount, mouse_position): #while stationary camera zoom is simple and straightforward, dynamic camera zoom allows one to zoom in to the area of where their mouse is
	if $Camera2D.zoom + zoom_amount > Vector2(0, 0):
		var camera_distance_from_mouse = $Camera2D.position - mouse_position
		$Camera2D.position = mouse_position + camera_distance_from_mouse * $Camera2D.zoom/($Camera2D.zoom + zoom_amount * $Camera2D.zoom)
	$Camera2D.zoom += zoom_amount #* $Camera2D.zoom ## <<-- remove previous comment for fluid camera zoom that does not stagnate
	
	set_labels()

func set_labels():
	zoom_label.text = str(snapped($Camera2D.zoom.x * 100, 0.01)) + "%"

func _on_minus_pressed():
	stationary_camera_zoom(-STATIONARY_CAMERA_ZOOM_AMOUNT)

func _on_plus_pressed():
	stationary_camera_zoom(STATIONARY_CAMERA_ZOOM_AMOUNT)

func _on_reset_pressed():
	$Camera2D.zoom = Vector2(1, 1)
	$Camera2D.position = camera_reset_position
	set_labels()

func _unhandled_input(event):
	if event is InputEventMouseButton:
		#if mouse wheel is scrolled
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			dynamic_camera_zoom(DYNAMIC_CAMERA_ZOOM_AMOUNT, get_global_mouse_position())

		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			dynamic_camera_zoom(-DYNAMIC_CAMERA_ZOOM_AMOUNT, get_global_mouse_position())
		
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if !event.pressed:
				graphs_that_received_input.clear()

	elif event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_LEFT:
			if spacebar_is_pressed: # camera panning.
				camera_pan(event.relative)
	
	elif Input.is_action_just_pressed("zoom_in"):
		stationary_camera_zoom(STATIONARY_CAMERA_ZOOM_AMOUNT)
	
	elif Input.is_action_just_pressed("zoom_out"):
		stationary_camera_zoom(-STATIONARY_CAMERA_ZOOM_AMOUNT)
