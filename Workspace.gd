extends Node2D

var spacebar_is_pressed = false # For camera movement - to pan the scene, hold space

const STATIONARY_CAMERA_ZOOM_AMOUNT = Vector2(0.2, 0.2)
const DYNAMIC_CAMERA_ZOOM_AMOUNT = STATIONARY_CAMERA_ZOOM_AMOUNT/4

var camera_reset_position = Vector2(610, 324)

signal camera_changed

@onready var infinite_grid = $Background/Grid2D
@onready var zoom_label = $Panel/LeftBoxContainer/VBoxContainer/PanelContainer/HBoxContainer/Label

func _ready():

	set_labels()
	_on_reset_pressed()


func _process(delta):

	set_camera_pan()


#Input-based functions

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

	elif event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_LEFT:
			if spacebar_is_pressed: # camera panning.
				camera_pan(event.relative)
	
	elif Input.is_action_just_pressed("zoom_in"):
		stationary_camera_zoom(STATIONARY_CAMERA_ZOOM_AMOUNT)
	
	elif Input.is_action_just_pressed("zoom_out"):
		stationary_camera_zoom(-STATIONARY_CAMERA_ZOOM_AMOUNT)
