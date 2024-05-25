extends Node2D

@export var minor_square_size := 30
@export var major_square_relative_sqrt := 4 #how many minor squares will create a major_square. Say the value is 4, then 4^2

@export var major_line_colour := Color(1, 1, 1, 0.8)
@export var minor_line_colour := Color(1, 1, 1, 0.4)

@export var draw_grid := false

var reference_pos
var cam_zoom: Vector2

var line_spacing 

func set_camera_information(zoom, ref):
	cam_zoom = zoom
	reference_pos = ref
	
	draw_grid = true

func _process(delta):
	queue_redraw()

func calculate_lines():
	line_spacing = minor_square_size * (fmod(cam_zoom.x, 1) + 1)
	
	var loop = true
	var line_number = 0
	var line_positions_x = [] #vertical lines
	
	# calculating all vertical lines to the left of the reference_pos
	while loop == true:
		line_positions_x.append(reference_pos.get_global_transform_with_canvas()[2].x - (line_spacing * line_number))
		
		line_number += 1
		
		if line_positions_x[line_number - 1] < 0:
			loop = false
	
	loop = true
	var right_line_number = 1
	
	#calculating all vertical lines to the right of the reference_pos
	while loop == true:
		line_positions_x.append(reference_pos.get_global_transform_with_canvas()[2].x + (line_spacing * right_line_number))
		
		line_number += 1
		right_line_number += 1
		
		if line_positions_x[line_number - 1] > get_viewport_rect().size.x:
			loop = false
	
	loop = true
	line_number = 0
	var line_positions_y = [] #horizontal lines
	
	#calculating all horizontal lines above the reference_pos
	while loop == true:
		line_positions_y.append(reference_pos.get_global_transform_with_canvas()[2].y - (line_spacing * line_number))
		
		line_number += 1
		
		if line_positions_y[line_number - 1] < 0:
			loop = false
	
	loop = true
	var bottom_line_number = 1
	
	#calculating all horizontal lines below the reference_pos
	while loop == true:
		line_positions_y.append(reference_pos.get_global_transform_with_canvas()[2].y + (line_spacing * bottom_line_number))
		
		line_number += 1
		bottom_line_number += 1
		
		if line_positions_y[line_number - 1] > get_viewport_rect().size.y:
			loop = false
	
	
	line_positions_x.sort()
	line_positions_y.sort()
	
	return [line_positions_x, line_positions_y]


func _draw():
	if draw_grid:
		var line_positions = calculate_lines() # = [vertical lines, horizontal lines]
		
		var loop = 0
		var line_number_of_reference_x
		for line in line_positions[0]:
			if line == reference_pos.get_global_transform_with_canvas()[2].x:
				line_number_of_reference_x = loop
			
			loop += 1
		
		loop = 0
		var line_number_of_reference_y
		for line in line_positions[1]:
			if line == reference_pos.get_global_transform_with_canvas()[2].y:
				line_number_of_reference_y = loop
			
			loop += 1
		
		
		var current_colour
		loop = 0
		
		for line in line_positions[0]: #drawing vertical lines
			if fmod(loop-line_number_of_reference_x, major_square_relative_sqrt) == 0:
#				print(line)
				current_colour = major_line_colour
			else:
				current_colour = minor_line_colour
			
			draw_line(Vector2(line, 0), Vector2(line, get_viewport_rect().size.y), current_colour)
			loop += 1
		
		loop = 0
		
		for line in line_positions[1]: #drawing horizontal lines
			if fmod(loop-line_number_of_reference_y, major_square_relative_sqrt) == 0:
				current_colour = major_line_colour
			else:
				current_colour = minor_line_colour
			
			draw_line(Vector2(0, line), Vector2(get_viewport_rect().size.x, line), current_colour)
			loop += 1

