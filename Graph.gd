extends Node2D

@onready var board = $Board

var mouse_on_board = false
var board_is_being_dragged = false
var board_drag_initial_position = Vector2()
var distance_from_dragging_mouse = Vector2()
var board_is_selected = false

var mouse_on_a_resize_handle = false
var selected_resize_handle = ""
var resize_handle_is_being_dragged = false
var initial_board_position
var initial_board_scale
var initial_mouse_position
var resize_handle_already_selected = false

var minimum_board_scale = 100

const BORDER_SELECT_COLOUR = "1a73e8"
const BORDER_NORMAL_COLOUR = "4b4b4b"

@onready var current_graph = null

@onready var inspectors = ["res://GraphScroll.tscn", "res://LineGraphScroll.tscn", "res://LineSeriesScroll.tscn"]

signal BoardSelect(node)
# handling_input will be handled by WorkingArea. WorkingArea receives BoardSelect signal, sets handling_input to false for all other graphs except for the highest priority one
var handling_input : bool = true

var dataset := {
	"x": [0, 1, 2, 3],
	"x2": [2, 3, 4, 5, 6],
	"y": [0, 2, 4, 6],
	"y2": [0, 4, 8, 12],
	"y3": [13, 10, 10, 4, -10]
}

func _ready():
	current_graph = $LineGraph
	if current_graph != null:
		current_graph.set_data(dataset)
	
	setup()
	redraw_graph()


func _process(delta):
	
	if handling_input:
		drag_chart(board_is_being_dragged)
		
	draw_resize_handles(board_is_selected)
	
	resize_graph(resize_handle_is_being_dragged, selected_resize_handle, get_global_mouse_position())


## Setting things up: functions

func setup():
	set_chart_size(720, 450) # aspect ratio of new chart = 16:10

func set_chart_size(x, y):
	board.show()
	board.scale = Vector2(x, y)


## 'drawing' functions

#called during _process
func draw_resize_handles(selected):
	var border_width = 2
	
	if selected:
		$ResizeHandles.show()
		
		$Border.modulate = BORDER_SELECT_COLOUR
		
		$ResizeHandles.get_node("TL").position = board.position - board.scale/2
		$ResizeHandles.get_node("TM").position = Vector2(board.position.x, board.position.y - board.scale.y/2)
		$ResizeHandles.get_node("TR").position = Vector2(board.position.x + board.scale.x/2, board.position.y - board.scale.y / 2)
		
		$ResizeHandles.get_node("BL").position = Vector2(board.position.x - board.scale.x/2, board.position.y + board.scale.y/2)
		$ResizeHandles.get_node("BM").position = Vector2(board.position.x, board.position.y + board.scale.y/2)
		$ResizeHandles.get_node("BR").position = board.position + board.scale/2
		
		$ResizeHandles.get_node("LM").position = Vector2(board.position.x - board.scale.x/2, board.position.y)
		$ResizeHandles.get_node("RM").position = Vector2(board.position.x + board.scale.x/2, board.position.y)
		
	else:
		$Border.modulate = BORDER_NORMAL_COLOUR
		$ResizeHandles.hide()

func redraw_graph():
	if current_graph != null:
		current_graph.update_graph()
	redraw_borders()

func redraw_borders():
	$Border.position = $Board.position
	$Border.scale = $Board.scale + Vector2(4, 4)

func emit_input():
	BoardSelect.emit(self.get_index())

func select_board(select: bool):
	board_is_selected = select
	handling_input = select

#Input-based functions

func _on_BoardArea2D_input_event(_viewport, _event, _shape_idx):
	mouse_on_board = true

func _on_BoardArea2D_mouse_exited():
	mouse_on_board = false

func drag_chart(dragging_board):

	if dragging_board:
		board.position = get_global_mouse_position() + distance_from_dragging_mouse
		redraw_graph()
	else:
		pass

func _unhandled_input(event):
	if event is InputEventMouseButton:
		# if mouse input is left click
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed: #if clicked

				if Input.is_action_pressed("spacebar") == false: #if the user is not panning the camera
					
					if mouse_on_a_resize_handle: #resize handle selected
						resize_handle_is_being_dragged = true
						initial_board_position = board.position
						initial_board_scale = board.scale
						initial_mouse_position = event.position
						resize_handle_already_selected = true

					elif mouse_on_board: #the mouse click is on the board
						board_is_being_dragged = true
						distance_from_dragging_mouse = board.position - get_global_mouse_position()
						
						board_is_selected = true
						#get_viewport().set_input_as_handled()
						BoardSelect.emit(self.get_index())
					
					else: #if the mouse click is not on the board or resize handle nor is space being pressed
						board_is_being_dragged = false
						board_is_selected = false
						mouse_on_a_resize_handle = false
						selected_resize_handle = ""
						resize_handle_is_being_dragged = false
				
				# if the input event is a spacebar (thus the user is panning the camera)
				else:
					board_is_being_dragged = false
					board_is_selected = false
					mouse_on_a_resize_handle = false
					selected_resize_handle = ""
					resize_handle_is_being_dragged = false
					
			else: #when the left click is released
				mouse_on_board = false
				board_is_being_dragged = false
				mouse_on_a_resize_handle = false
				selected_resize_handle = ""
				resize_handle_is_being_dragged = false
				resize_handle_already_selected = false
				
				handling_input = true

#Resize Handles Input Functions
func _on_TL_input_event(viewport, event, shape_idx):
	mouse_on_a_resize_handle = true
	if !resize_handle_already_selected:
		selected_resize_handle = "TL"

func _on_TM_input_event(viewport, event, shape_idx):
	mouse_on_a_resize_handle = true
	if !resize_handle_already_selected:
		selected_resize_handle = "TM"

func _on_TR_input_event(viewport, event, shape_idx):
	mouse_on_a_resize_handle = true
	if !resize_handle_already_selected:
		selected_resize_handle = "TR"

func _on_BL_input_event(viewport, event, shape_idx):
	mouse_on_a_resize_handle = true
	if !resize_handle_already_selected:
		selected_resize_handle = "BL"

func _on_BM_input_event(viewport, event, shape_idx):
	mouse_on_a_resize_handle = true
	if !resize_handle_already_selected:
		selected_resize_handle = "BM"

func _on_BR_input_event(viewport, event, shape_idx):
	mouse_on_a_resize_handle = true
	if !resize_handle_already_selected:
		selected_resize_handle = "BR"

func _on_LM_input_event(viewport, event, shape_idx):
	mouse_on_a_resize_handle = true
	if !resize_handle_already_selected:
		selected_resize_handle = "LM"

func _on_RM_input_event(viewport, event, shape_idx):
	mouse_on_a_resize_handle = true
	if !resize_handle_already_selected:
		selected_resize_handle = "RM"

func _on_TL_mouse_exited():
	mouse_on_a_resize_handle = false

func _on_TM_mouse_exited():
	mouse_on_a_resize_handle = false

func _on_TR_mouse_exited():
	mouse_on_a_resize_handle = false

func _on_BL_mouse_exited():
	mouse_on_a_resize_handle = false

func _on_BM_mouse_exited():
	mouse_on_a_resize_handle = false

func _on_BR_mouse_exited():
	mouse_on_a_resize_handle = false

func _on_LM_mouse_exited():
	mouse_on_a_resize_handle = false

func _on_RM_mouse_exited():
	mouse_on_a_resize_handle = false


func resize_graph(being_dragged, resize_handle, mouse_position, resize_mode="normal"):
	if being_dragged:
		if resize_mode == "normal":
			if resize_handle == "TL":
				# BELOW: scaling the board without aspect ratio
#				board.scale = (initial_board_position + initial_board_scale/2) - mouse_position
#				board.position = (mouse_position + (initial_board_position + initial_board_scale/2))/2
				
				var mouse_position_from_TL_corner = mouse_position - (board.position - board.scale/2)
				if mouse_position_from_TL_corner.x < mouse_position_from_TL_corner.y:
					#if the mouse is closer to the left edge of the board
					board.scale = Vector2((initial_board_position.x + initial_board_scale.x/2) - mouse_position.x, ((initial_board_position.x + initial_board_scale.x/2) - mouse_position.x)/initial_board_scale.x * initial_board_scale.y)
					
					if board.scale.x < minimum_board_scale:
						if initial_board_scale.x <= initial_board_scale.y:
							board.scale = Vector2(minimum_board_scale, initial_board_scale.y/initial_board_scale.x*minimum_board_scale)
						else:
							board.scale = Vector2(initial_board_scale.x/initial_board_scale.y*minimum_board_scale, minimum_board_scale)
					elif board.scale.y < minimum_board_scale:
						if initial_board_scale.x < initial_board_scale.y:
							board.scale = Vector2(minimum_board_scale, initial_board_scale.y/initial_board_scale.x*minimum_board_scale)
						else:
							board.scale = Vector2(initial_board_scale.x/initial_board_scale.y*minimum_board_scale, minimum_board_scale)
					
					board.position = initial_board_position + initial_board_scale/2 - board.scale/2
				else:
					board.scale = Vector2(((initial_board_position.y + initial_board_scale.y/2) - mouse_position.y)/initial_board_scale.y * initial_board_scale.x,
					(initial_board_position.y + initial_board_scale.y/2) - mouse_position.y)
					
					if board.scale.x < minimum_board_scale:
						if initial_board_scale.x <= initial_board_scale.y:
							board.scale = Vector2(minimum_board_scale, initial_board_scale.y/initial_board_scale.x*minimum_board_scale)
						else:
							board.scale = Vector2(initial_board_scale.x/initial_board_scale.y*minimum_board_scale, minimum_board_scale)
					elif board.scale.y < minimum_board_scale:
						if initial_board_scale.x < initial_board_scale.y:
							board.scale = Vector2(minimum_board_scale, initial_board_scale.y/initial_board_scale.x*minimum_board_scale)
						else:
							board.scale = Vector2(initial_board_scale.x/initial_board_scale.y*minimum_board_scale, minimum_board_scale)
					
					board.position = initial_board_position + initial_board_scale/2 - board.scale/2
			
			elif resize_handle == "TM":
				board.scale.y = initial_board_position.y + initial_board_scale.y/2 - mouse_position.y
				if board.scale.y > minimum_board_scale:
					board.position.y = (mouse_position.y + (initial_board_position.y + initial_board_scale.y/2))/2
				else:
					board.scale.y = minimum_board_scale
					board.position.y = initial_board_position.y + initial_board_scale.y/2 - minimum_board_scale/2
			
			elif resize_handle == "TR":
				var mouse_position_from_TR_corner = -mouse_position + (Vector2(board.position.x + board.scale.x/2, board.position.y - board.scale.y/2))
				
				if mouse_position_from_TR_corner.x < -mouse_position_from_TR_corner.y:
					#if the mouse is closer to the right edge of the board
					board.scale = Vector2(mouse_position.x - (initial_board_position.x - initial_board_scale.x/2), (mouse_position.x - (initial_board_position.x - initial_board_scale.x/2))/initial_board_scale.x * initial_board_scale.y)

					if board.scale.x < minimum_board_scale:
						if initial_board_scale.x <= initial_board_scale.y:
							board.scale = Vector2(minimum_board_scale, initial_board_scale.y/initial_board_scale.x*minimum_board_scale)
						else:
							board.scale = Vector2(initial_board_scale.x/initial_board_scale.y*minimum_board_scale, minimum_board_scale)
					elif board.scale.y < minimum_board_scale:
						if initial_board_scale.x < initial_board_scale.y:
							board.scale = Vector2(minimum_board_scale, initial_board_scale.y/initial_board_scale.x*minimum_board_scale)
						else:
							board.scale = Vector2(initial_board_scale.x/initial_board_scale.y*minimum_board_scale, minimum_board_scale)

					board.position = ((Vector2(initial_board_position.x - initial_board_scale.x/2, initial_board_position.y + initial_board_scale.y/2)) + (Vector2(initial_board_position.x - initial_board_scale.x/2, initial_board_position.y + initial_board_scale.y/2) + Vector2(board.scale.x, -board.scale.y)))/2
				else:
					#if the mouse is closer to the top edge of the board
					board.scale = Vector2(((initial_board_position.y + initial_board_scale.y/2) - mouse_position.y)/initial_board_scale.y * initial_board_scale.x, (initial_board_position.y + initial_board_scale.y/2) - mouse_position.y)
					
					if board.scale.x < minimum_board_scale:
						if initial_board_scale.x <= initial_board_scale.y:
							board.scale = Vector2(minimum_board_scale, initial_board_scale.y/initial_board_scale.x*minimum_board_scale)
						else:
							board.scale = Vector2(initial_board_scale.x/initial_board_scale.y*minimum_board_scale, minimum_board_scale)
					elif board.scale.y < minimum_board_scale:
						if initial_board_scale.x < initial_board_scale.y:
							board.scale = Vector2(minimum_board_scale, initial_board_scale.y/initial_board_scale.x*minimum_board_scale)
						else:
							board.scale = Vector2(initial_board_scale.x/initial_board_scale.y*minimum_board_scale, minimum_board_scale)
					
					board.position = ((Vector2(initial_board_position.x - initial_board_scale.x/2, initial_board_position.y + initial_board_scale.y/2)) + (Vector2(initial_board_position.x - initial_board_scale.x/2, initial_board_position.y + initial_board_scale.y/2) + Vector2(board.scale.x, -board.scale.y)))/2

			elif resize_handle == "BL":
				var mouse_position_from_BL_corner = mouse_position - (Vector2(board.position.x - board.scale.x/2, board.position.y + board.scale.y/2))
				
				if -mouse_position_from_BL_corner.x > mouse_position_from_BL_corner.y: 
					# if the mouse is closer to the left edge of the board
					board.scale = Vector2(initial_board_position.x + initial_board_scale.x/2 - mouse_position.x, (initial_board_position.x + initial_board_scale.x/2 - mouse_position.x)/initial_board_scale.x * initial_board_scale.y)

					if board.scale.x < minimum_board_scale:
						if initial_board_scale.x <= initial_board_scale.y:
							board.scale = Vector2(minimum_board_scale, initial_board_scale.y/initial_board_scale.x*minimum_board_scale)
						else:
							board.scale = Vector2(initial_board_scale.x/initial_board_scale.y*minimum_board_scale, minimum_board_scale)
					elif board.scale.y < minimum_board_scale:
						if initial_board_scale.x < initial_board_scale.y:
							board.scale = Vector2(minimum_board_scale, initial_board_scale.y/initial_board_scale.x*minimum_board_scale)
						else:
							board.scale = Vector2(initial_board_scale.x/initial_board_scale.y*minimum_board_scale, minimum_board_scale)

					board.position = Vector2(initial_board_position.x + initial_board_scale.x/2 - board.scale.x/2, initial_board_position.y - initial_board_scale.y/2 + board.scale.y/2)

				else:
					# if the mouse is closer to the bottom edge of the board
					board.scale = Vector2((mouse_position.y - (initial_board_position.y-initial_board_scale.y/2))/initial_board_scale.y * initial_board_scale.x, mouse_position.y - (initial_board_position.y-initial_board_scale.y/2))

					if board.scale.x < minimum_board_scale:
						if initial_board_scale.x <= initial_board_scale.y:
							board.scale = Vector2(minimum_board_scale, initial_board_scale.y/initial_board_scale.x*minimum_board_scale)
						else:
							board.scale = Vector2(initial_board_scale.x/initial_board_scale.y*minimum_board_scale, minimum_board_scale)
					elif board.scale.y < minimum_board_scale:
						if initial_board_scale.x < initial_board_scale.y:
							board.scale = Vector2(minimum_board_scale, initial_board_scale.y/initial_board_scale.x*minimum_board_scale)
						else:
							board.scale = Vector2(initial_board_scale.x/initial_board_scale.y*minimum_board_scale, minimum_board_scale)

					board.position = Vector2(initial_board_position.x + initial_board_scale.x/2 - board.scale.x/2, initial_board_position.y - initial_board_scale.y/2 + board.scale.y/2)
			
			elif resize_handle == "BM":
				board.scale.y = mouse_position.y - (initial_board_position.y - initial_board_scale.y/2)
				if board.scale.y > minimum_board_scale:
					board.position.y = (initial_board_position.y - initial_board_scale.y/2 + mouse_position.y)/2
				else:
					board.scale.y = minimum_board_scale
					board.position.y = initial_board_position.y - initial_board_scale.y/2 + minimum_board_scale/2
			
			elif resize_handle == "BR":
				var mouse_position_from_BR_corner = mouse_position - (Vector2(board.position.x + board.scale.x/2, board.position.y + board.scale.y/2))
				
				if -mouse_position_from_BR_corner.x < -mouse_position_from_BR_corner.y:
					# if the mouse is closer to the right edge of the board.
					board.scale = Vector2(mouse_position.x - (initial_board_position.x - initial_board_scale.x/2), ((mouse_position.x - (initial_board_position.x - initial_board_scale.x/2)))/initial_board_scale.x * initial_board_scale.y)
					
					if board.scale.x < minimum_board_scale:
						if initial_board_scale.x <= initial_board_scale.y:
							board.scale = Vector2(minimum_board_scale, initial_board_scale.y/initial_board_scale.x*minimum_board_scale)
						else:
							board.scale = Vector2(initial_board_scale.x/initial_board_scale.y*minimum_board_scale, minimum_board_scale)
					elif board.scale.y < minimum_board_scale:
						if initial_board_scale.x < initial_board_scale.y:
							board.scale = Vector2(minimum_board_scale, initial_board_scale.y/initial_board_scale.x*minimum_board_scale)
						else:
							board.scale = Vector2(initial_board_scale.x/initial_board_scale.y*minimum_board_scale, minimum_board_scale)
					
					board.position = Vector2(initial_board_position.x - initial_board_scale.x/2 + board.scale.x/2, initial_board_position.y - initial_board_scale.y/2 + board.scale.y/2)

				else:
					board.scale = Vector2((mouse_position.y - (initial_board_position.y - initial_board_scale.y/2))/initial_board_scale.y * initial_board_scale.x, mouse_position.y - (initial_board_position.y - initial_board_scale.y/2))
					
					if board.scale.x < minimum_board_scale:
						if initial_board_scale.x <= initial_board_scale.y:
							board.scale = Vector2(minimum_board_scale, initial_board_scale.y/initial_board_scale.x*minimum_board_scale)
						else:
							board.scale = Vector2(initial_board_scale.x/initial_board_scale.y*minimum_board_scale, minimum_board_scale)
					elif board.scale.y < minimum_board_scale:
						if initial_board_scale.x < initial_board_scale.y:
							board.scale = Vector2(minimum_board_scale, initial_board_scale.y/initial_board_scale.x*minimum_board_scale)
						else:
							board.scale = Vector2(initial_board_scale.x/initial_board_scale.y*minimum_board_scale, minimum_board_scale)
					
					board.position = Vector2(initial_board_position.x - initial_board_scale.x/2 + board.scale.x/2, initial_board_position.y - initial_board_scale.y/2 + board.scale.y/2)
			
			elif resize_handle == "LM":
				board.scale.x = initial_board_position.x + initial_board_scale.x/2 - mouse_position.x
				if board.scale.x > minimum_board_scale:
					board.position.x = (mouse_position.x + initial_board_position.x + initial_board_scale.x/2)/2
				else:
					board.scale.x = minimum_board_scale
					board.position.x = initial_board_position.x + initial_board_scale.x/2 - minimum_board_scale/2
			
			elif resize_handle == "RM":
				board.scale.x = mouse_position.x - (initial_board_position.x - initial_board_scale.x/2)
				if board.scale.x > minimum_board_scale:
					board.position.x = (initial_board_position.x - initial_board_scale.x/2 + mouse_position.x)/2
				else:
					board.scale.x = minimum_board_scale
					board.position.x = initial_board_position.x - initial_board_scale.x/2 + minimum_board_scale/2
		
		
		elif resize_mode == "scale":
			pass #to do!
		
		redraw_graph()
	
	else:
		pass
