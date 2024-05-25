extends Node2D

@onready var board = $Graph/Board

var clicked_on_board = false
var board_is_being_dragged = false
var board_drag_initial_position = Vector2()
var distance_from_dragging_mouse = Vector2()

func _ready():
	
	create_new()
	redraw_graph()

func redraw_graph():
	$Graph.from_parent_redraw_graph()

func _process(delta):
	drag_chart(board_is_being_dragged)
	draw_resize_handles(clicked_on_board)

func create_new():
	set_chart_size(720, 450) # aspect ratio of new chart = 16:10

func set_chart_size(x, y):
	board.show()
	board.scale = Vector2(x, y)

#Input-based functions

func _on_BoardArea2D_input_event(_viewport, _event, _shape_idx):
	clicked_on_board = true

func drag_chart(dragging_board):
	
	if dragging_board:
		board.position = get_viewport().get_mouse_position() + distance_from_dragging_mouse
		redraw_graph()
	else:
		pass

func draw_resize_handles(click):
	pass

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if clicked_on_board:
					board_is_being_dragged = true
					distance_from_dragging_mouse = board.position - get_viewport().get_mouse_position()
				print("Left button was clicked at ", event.position)
			else:
				if clicked_on_board:
					clicked_on_board = false
					board_is_being_dragged = false
					print(clicked_on_board)
				print("Left button was released at ", event.position)
				pass
