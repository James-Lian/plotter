#with and without x-axis, and multi line graphs, with or wthout markers (the points of data), with or without multiple y-axis or multiple x-axis, quadrant or non-quadrant

### IMPORTANT MESSAGE: FOR ALL DICTIONARIES, NULL CANNOT BE A VALID KEY

extends Node2D

@onready var Title = $MarginContainer/VBoxContainer/Title

var no_data := false
var default_font = Globals.global_default_font
var default_font_bold = Globals.global_default_font_bold

var current_font = {
	"title": "",
	"vertical axis labels": ""
}
var current_font_bold = {
	"title": ""
}
var current_font_italics = {
	"title": ""
}
var current_font_bold_italics = {
	"title": ""
}

var title_rect : Array = []
var subtitle_rect : Vector2

#Workspace - the locations of the corners of the graphing area for the lines
var topl: Vector2 = Vector2()
var bottomr: Vector2 = Vector2()
var topr: Vector2 = Vector2(bottomr.x, topl.y)
var bottoml: Vector2 = Vector2(topl.x, bottomr.y)

# there needs to be a "border", and these values are responsible for it.
var inner_topl: Vector2 = Vector2()
var inner_bottomr: Vector2 = Vector2()
var inner_topr: Vector2 = Vector2(inner_bottomr.x, inner_topl.y)
var inner_bottoml: Vector2 = Vector2(inner_topl.x, inner_bottomr.y)

# Real workspace values are for the corner of the entire whiteboard area - not just the area for the lines
var real_topl: Vector2 = Vector2()
var real_bottomr: Vector2 = Vector2()
var real_topr: Vector2 = Vector2(bottomr.x, topl.y)
var real_bottoml: Vector2 = Vector2(topl.x, bottomr.y)

# for a variable number of series. 
var dataset := {
	"x": [0, 1, 2, 3],
	"x2": [2, 3, 4, 5, 6],
	"y": [0, 2, 4, 6],
	"y2": [0, 4, 8, 12],
	"y3": [13, 10, 10, 4, -10]
}

# a dictionary full of Class Series
var series_dict = {
	
}

@onready var board = get_parent().get_node("Board")

var largest_point_size = Vector2(0, 0)

## List of the biggest maximum values of all the series associated within each y-axis. Is used in graphing to determine the suitable range that is able to depict all of the graphed series.
var biggest_max_values = []

## List of the smallest minimum values of all the series associated within each y-axis. Is used in graphing to determine the suitable range that is able to depict all of the graphed series.
var smallest_min_values = []

## Now, when you're working on a graph with multiple y-axes, things get complicated. Different y-axes have different values, and they need to have different scales. For an automatic setting, the graph will automatically create gridlines based on two rules: use the y-axis scales of 1, 2, 2.5, and 5 (multipled to whatever power of 10 is needed), and there must be a minimum of 3 gridlines and a maximum of 5 (for the automatic setting. You can manually adjust the number of gridlines to whatever you want.) [br]But how would you integrate multiple y-axes into gridline system? Well, what I plan to do is this: first, in the 'main' y-axis, find the biggest and smallest values and use that as the range. From them on, find a scale (1, 2, 2.5, 5, et cetera) that works. "But James!" I hear you say. 1, 2, 2.5, and 5 is not inclusive of all the kinds of data your graph maker would accomodate! What about a series like [4, 8, 12, 16] ? You said there would be a maximum of 5 gridlines in the automatic setting, so the scale of 2 would not work. A scale like 4 is not included in the y-axis scales you said you would be working with! [br]Worry not my friend. It's quite simple. I'll use 4 gridlines with a scale of 5, making the maximum value 20. The maximum value of 20 will be stored within adjusted_max_values to be used while drawing the line_graph. This means there will be a gap of around 4 units between the top of the graph and the largest value in the series of [4, 8, 12, 16]. In a certain function, there will automatically be a string of code to determine the most suitable scale. 
var adjusted_max_values := []

## see adjusted_max_values
var adjusted_min_values := []

var horizontal_max_values := {}
var horizontal_min_values := {}

var main_x_axis = ""

var number_of_gridlines := 0

var list_of_vertical_major_gridlines : Array = []

var list_of_vertical_minor_gridlines : Array = []

var list_of_horizontal_major_gridlines : Array = []

var list_of_horizontal_minor_gridlines : Array = []

var lines_to_draw = {
	
}

## Chart_parameters are parameters that concern the entire chart, ex: the appearance of the title, whether the graph will be maximised or not, the chart's legend.

# !! CREATE DEFAULT CHART_PARAMETERS VARIABLE OR CREATE A FUNCTION THAT MAKES A VALUE DEFAULT AGAIN!!

var DEFAULT_CHART_PARAMETERS = {
	"maximised" : true,
	
	"inner graph boundary": { # only if the graph isn't maximised
		"draw": true,
		"weight": 1,
		"colour": Color(0.6, 0.6, 0.6, 1)
	},

	"graph inner margins": {
		"top": 10,
		"bottom": 10,
		"left": 10,
		"right": 10
	}, # applies to the everything except a maximised graph
	
	"title" : {
		"text" : "",
		"visible" : true,
		"size" : -1, ## later, -1 for auto
		"font" : default_font, 
		"bold" : false,
		"custom bold font": default_font_bold,
		"italic" : false,
		"custom italic font": "",
		"custom bold italic font" : "",
		"colour" : Color(0, 0, 0, 1),
		"alignment options": ["left", "center", "right"],
		"selected alignment": 0,
		
		"draw outline": true,
		"outline weight": 12,
		"outline colour": Color(1, 1, 1, 1)
	},
	
	"subtitle" : {
		"text": "",
		"visible": true,
		"size": -1,
		"font": default_font,
		"bold": false,
		"custom bold font": default_font_bold,
		"italic": false,
		"custom italic font": "",
		"custom bold italic font": "",
		"colour": Color(0.4, 0.4, 0.4, 1),
		"aligntment options": ["left", "center", "right"],
		"selected alignment": 0,
		
		"draw outline": false,
		"outline weight": 10,
		"outline colour": Color(1, 1, 1, 1)
	},
	
	# !! FOR VERTICAL + HORIZONTAL AXIS LABELS< MAKE SURE TO PUT LIMIT ON HOW MANY LABELS THERE ARE!!
	
	"vertical axis titles" : {
		"rotated": true,
		"colours": [],
		"texts": [],
	},
	
	"vertical axis labels" : {
		"visible": true,
		"size": 16,
		"font": default_font,
		"colour": Color(0.3, 0.3, 0.3, 1),
		"labelled decimal precision (power of ten)": 0.01, # null if not applicable
		
		"draw outline": true,
		"outline weight": 4,
		"outline colour": Color(1, 1, 1, 1)
	},
	
	"horizontal axis titles": {
		
	},
	
	"horizontal axis labels": {
		"labelled decimal precision (power of ten)": 0.01 # null if not applicable
	},
	
	# This is what's going to happen with x-axes: by default, when you create a graph with multiple x-axes, the lines will be coloured the same colour as their x-axis. If you choose to further edit the colours, then that's up to you, but by default, the lines will be coloured the same colour as their linked x-axis. If there's multiple lines sharing the same x-axis, there can be slight variations in hue or saturation or whatever.
	"x axes" : {},
	
	"main x axis": null,
	
	# if there are min max values for an x axis, key-value it. Otherwise, make the value null! The key will be deleted in update_functional_values.
	"x axis min values": {},
	"x axis max values": {},
	
	"highlight lines with linked x axes" : false, 
	
	"y axes": [[]], # there is ONE main y-axis, and that's the left y-axis. All series that are added to the LineGraph will start out being graphed in the MAIN LEFT Y-AXIS. If the user intends, they can separate a specified series into its own y-axis. If the user wants *multiple* series dedicated to *another* y-axis, then we add it as a sub-list.
	
	"y axis min values": [null],
	"y axis max values": [null],
	
	# Automatic guide-and-tick setting rules! Maximum 5 major guides! Minimum 3! Minor guides can be manually set. For anything past 125, gridlines must be multiples of 25! 25 + 25 = 50. 50 can service between 150 (50 * 3) and 250 (50 * 5)! 50 + 50 = 100. 250, 500, 1000, 2000, 2500, 5000. It keeps going 1, 2, 2.5, 5. 
	# BTW, for series with only positive values, the automatic minimum value is 0!
	"vertical gridlines and ticks": {
		
		"major gridlines": {
			"weight": 1,
			"colour": Color(0.3, 0.3, 0.3, 1),
			"scale": null, # null if set to automatic behaviour, units are based on the scale of the main y-axis
			
			"style": ["solid", "dashed", "dash and dot"],
			"selected style": 0
		},
		"minor gridlines": {
			"draw": true,
			"weight": 1,
			"colour": Color(0.7, 0.7, 0.7, 1),
			"count": 2
			
			## below parameters TBD
#			"style": ["solid", "dashed", "dash and dot"],
#			"selected style": 0
		},

		"major ticks": {
			"draw": false,
			"weight": 3,
			"colour": Color(0.1, 0.1, 0.1, 1),
			
			"position": ["inside", "outside", "crossed"], # not applicable in maximised view
			"selected position": 0,
			
			"length": 2
		},
		"minor ticks": {
			"draw": false,
			"weight": 3,
			"colour": Color(0.3, 0.3, 0.3, 1),
			
			"position": ["inside", "outside", "crossed"], # not aplicable in maximised view
			"selected position": 0,
			
			"length": 2
		},
		
		# value gridlines and ticks are gridlines/ticks drawn to show the specific x and y values of a specific point on the graph. They will be drawn in the same colour as the Series they are representing.
		"value gridlines": {
			
		},
		"value ticks": {
			
		},
		
		# these default parameters change with each recent adjustment made to an existing custom value gridline. Each time a custom gridline is changed, the "default custom gridline parameters" variable changes to match the edited gridline's parameters
		"gridline style parameters": {
			
		}
	},
	
	"horizontal gridlines and ticks": {
		"major gridlines": {
			"weight": 1,
			"colour": Color(0.3, 0.3, 0.3, 1),
			"scale": null, # null if set to automatic behaviour, units are based on the scale of the main y-axis
			
			"style": ["solid", "dashed", "dash and dot"],
			"selected style": 0
		},
		"minor gridlines": {
			"draw": true,
			"weight": 1,
			"colour": Color(0.7, 0.7, 0.7, 1),
			"count": 1,
			
			"style": ["solid", "dashed", "dash and dot"],
			"selected style": 0
		},

		"major ticks": {
			"draw": false,
			"weight": 3,
			"colour": Color(0.1, 0.1, 0.1, 1),
			
			"position": ["inside", "outside", "crossed"], # not applicable in maximised view
			"selected position": 0,
			
			"length": 2
		},
		"minor ticks": {
			"draw": false,
			"weight": 3,
			"colour": Color(0.3, 0.3, 0.3, 1),
			
			"position": ["inside", "outside", "crossed"], # not aplicable in maximised view
			"selected position": 0,
			
			"length": 2
		},
		
		# value gridlines and ticks are gridlines/ticks drawn to show the specific x and y values of a specific point on the graph. They will be drawn in the same colour as the Series they are representing.
		"value gridlines": {
			
		},
		"value ticks": {
			
		},
	},
	
	"legend and multiple axes": {
		"show legend" : false,
		"legend positions" : ["top", "bottom", "left", "right", "inside", "labelled"],
		"selected position" : 0,
	}
	
}

var chart_parameters = DEFAULT_CHART_PARAMETERS.duplicate()

## A Series is a list of values where the order matters. The values of a Series are what is depicted on a graph.
class Series:
	
	## If the series contains valid mathematical/numerical values that can be graphed. In the case of a Series which is composed of words (ex: ['Months', 'January', 'February', 'March'], ones that are used for categories) that cannot be used to mathematically compute aspects of the graph, the valid_series property will be set to false. Series which have a false valid_series property will most likely be used for the x-axis, or won't be graphed at all.
	var valid_series = false
	
	# If applicable
	var treat_as_text = false
	# Will be an option on the GUI to treat the series as text or not.
	func toggle_treat_series_as_text(toggle: bool):
		treat_as_text = toggle

	## The numerical information, the actual 'series' of the Series. Valid numerical values are as they are, but invalid values (strings) are replaced with null.
	var series = [] # includes valid and invalid values, invalid values are replaced with 'null'
	
	## The numerical values of the series only.
	var valid_values = [] # valid numerical values only
	
	## The series as it is, including valid and invalid values as they are.
	var real_series = [] # the series as it is
	
	## A copy of the default_series_parameters used for functional and cosmetic aspects of the graph.
	var default_series_parameters = {
		"smooth" : false,
		"ignore void values" : false, # PROBLEM WITH IGNORE VOID VALUES!!!
		"scale break" : [false], #first item is false if no scale break, otherwise, every two items will be used for a scale break
		"trendline" : false,
		"show labels" : false,
		"display values" : false,
		
		"line" : {
			"colour": Color(0, 0, 0, 1), # CAN SET COLOUR WITH COLOUR PICKER !!
			"style": ["solid", "dashed", "dash and dot"],
			"selected style": 0,
			"weight": 3 #this is draw_line thickness for a constant weight unaffected by zoom
		},
		
		"points" : {
			"plot points": false,
			"point size": Vector2(10, 10),
			"point colour": Color(0, 0, 0),
			
			"custom point" : false,
			"custom point texture": "C:/",
			"custom point modulate": Color(1, 1, 1, 1),
			"custom point size": Vector2(0, 0)
		}
	}
	
	## series_parameters regard any properties that directly concern themselves with each individual series, ex: the colour of the Series' line. 
	var series_parameters = {
		
	}
	
	func determine_valid_item(value):
		if typeof(value) == TYPE_INT:
			return true
		elif typeof(value) == TYPE_FLOAT:
			return true
		else:
			return false
		
	
	func determine_valid_series():
		var list_of_readable_values = [] # the items in this list are either a valid item (see determine_valid_item()) or 'null'
		
		real_series = series
		
		for item in series:
			var value
			# if the value is a percentage
			for character in str(item):
				if character == "%":
					item = item.replace('%', "")
					break
			
			if determine_valid_item(item):
				valid_values.append(item)
				list_of_readable_values.append(item)
			else:
				list_of_readable_values.append(null)
		
		if valid_values != []: #if there *are* valid values
			series = list_of_readable_values
			valid_series = true
			return
		
		valid_series = false #if there aren't valid values
	
	func set_up(arr):
		series = arr
		determine_valid_series()
		set_default_dataset_parameters()
	
	func set_default_dataset_parameters():
		if valid_series:
			series_parameters = default_series_parameters
	
	# Utility/Fun functions
	## Ignores invalid (null) values.
	func find_min_value(array):
		var return_array = []
		
		if valid_series:
			for item in array:
				if item != null: # if the item is a valid value
					return_array.append(item)
		
			return_array.sort()
			
			return return_array[0]
	
	## Ignores invalid (null) values.
	func find_max_value(array):
		var return_array = []
		
		if valid_series:
			for item in array:
				if item != null: # if the item is a valid value
					return_array.append(item)
		
			return_array.sort()
			return return_array.back()
	
	func find_mean(para_series):
		if valid_series:
			var sum
			for item in para_series:
				sum += item
			return sum / len(para_series)
	
	func find_median(para_series):
		para_series.sort()
		if len(para_series) % 2 == 0:
			var median = (float(para_series[len(para_series)/2 - 1]) + float(para_series[len(para_series) / 2]))/2
			return median
		
		var median = (para_series[len(para_series)/2])
		return median
	
	func find_modes(para_series):
		var mode_dict = {

		}
		for item in para_series:
			mode_dict[item] = 0

		for item in para_series:
			mode_dict[item] += 1

		var no_mode = true
		for key in mode_dict:
			if mode_dict[key] > 1:
				no_mode = false
		if no_mode:
			return [null]

		var greatest_num = 1
		for key in mode_dict:
			if mode_dict[key] > greatest_num:
				greatest_num = mode_dict[key]

		var modes = []
		for key in mode_dict:
			if mode_dict[key] == greatest_num:
				modes.append(key)

		modes.sort()
		return modes
	
	func find_range(para_series):
		var return_array = []
		
		if valid_series:
			for item in para_series:
				if item != null: # if the item is a valid value
					return_array.append(item)
		return_array.sort()
		return float(return_array.back()) - float(return_array[0])
	
	func is_series_positive() -> bool:
		var is_positive := true
		
		for item in valid_values:
			if item < 0:
				is_positive = false
		
		return is_positive


## UTILITY FUNCTIONS

## Returns the value's associated key from the specified dictionary.
func find_key_from_dictionary_list(value, dict):
	var return_key = null
	
	for list in dict:
		for item in dict[list]:
			if item == value:
				return_key = list
	
	return return_key

func return_list_of_values_from_dictionary_lists(dict):
	var list_of_values = []
	
	for list in dict:
		for item in dict[list]:
			list_of_values.append(item)
	
	return list_of_values

func move_value_in_sublists(value, list: Array, original_position: int, new_position: int):
	# erases the value from the original sublist
	list[original_position].erase(value)
	
	# moves the value to another sublist. If the sublist does not exist, create a new one. 
	if len(list)-1 < new_position:
		list.append([])
		
		list[len(list)-1].append(value)
	else:
		list[new_position].append(value)

	return list

func return_sublists_as_list(list: Array) -> Array:
	var full_list = []

	for sublist in list:
		for item in sublist:
			full_list.append(item)
	return full_list

func return_with_sorted_sublists(list: Array) -> Array:
	for sublist in list:
		sublist.sort()
	
	return list

## Returns -1 if the value cannot be found.
func return_sublist_index_from_sublist_value(value, list) -> int:
	var index = -1
	
	var loop = 0
	for sublist in list:
		for item in sublist:
			if item == value:
				index = loop
		
		loop += 1
	
	return index

func clamp_minimum(value: int, min: int):
	if value < min:
		value = min
	
	return value

func ceil_floor(value, up_or_down: bool):
	if up_or_down:
		return ceil(value)
	else:
		return floor(value)

func return_all_below_zero(list):
	var return_list
	
	for x in list:
		if x < 0:
			return_list.append(x)
	
	return return_list

func return_all_above_zero(list):
	var return_list
	
	for x in list:
		if x > 0:
			return_list.append(x)
	
	return return_list

func ceil_floor_snapped(value, round_value, round_direction: bool):
	var return_value = 0.0
	
	if round_direction:
		return_value = snapped(value, round_value)
		if return_value < value:
			return_value += (round_value * 2)
	else:
		return_value = snapped(value, round_value)
		if return_value > value:
			return_value -= (round_value * 2)
	
	return return_value

func position_inside_rect(pos: Vector2, topl: Vector2, bottomr: Vector2) -> bool:
	if pos.x > topl.x and pos.x < bottomr.x:
		if pos.y > topl.y and pos.y < bottomr.y:
			return true
	
	return false

func rect_inside_another_rect(topl1: Vector2, bottomr1: Vector2, topl2: Vector2, bottomr2: Vector2) -> bool:
	# to check if a rectangle is inside another rectangle is easy. I already have a function position_inside_rect() which checks if a point is inside a rectangle, so to check if a *rectangle* is inside another *rectangle*, all you need to do is check whether any of the four vertices of rectangle1 are inside rectangle2.
	
	# checking top left corner
	if position_inside_rect(topl1, topl2, bottomr2):
		return true
	
	# checking top right corner
	if position_inside_rect(Vector2(bottomr1.x, topl1.y), topl2, bottomr2):
		return true
	
	if position_inside_rect(Vector2(topl1.x, bottomr1.y), topl2, bottomr2):
		return true
	
	if position_inside_rect(bottomr1, topl2, bottomr2):
		return true
	
	return false

## LINE GRAPH FUNCTIONS
func set_workspace():
	
	## real_topl and real_bottomr refer to the actual boundaries of the graph; where the board starts and ends (although inner graph margins still apply). 
	## Normal topl and bottomr refer to the drawing area of the actual graph; where the program will draw the lines and data. The labels and title, for example, will lie outside the area of the topl and bottomr and fall within the area of the real_topl and real_bottomr.
	
	# if the graph is maximised // the graph margins are not taken into account in the calculation of real_topl and real_bottomr. 
	# else // real_topl and real_bottomr will adjust according to the ['graph inner margins']
	var top_left_graph_margins : Vector2 = Vector2(0, 0)
	var bottom_right_graph_margins : Vector2 = Vector2(0, 0)
	if chart_parameters['maximised'] != true:
		top_left_graph_margins = Vector2(chart_parameters['graph inner margins']['top'], chart_parameters['graph inner margins']['left'])
		bottom_right_graph_margins = Vector2(chart_parameters['graph inner margins']['bottom'], chart_parameters['graph inner margins']['right'])
	
	real_topl = Vector2(board.position.x-board.scale.x/2, board.position.y-board.scale.y/2) + top_left_graph_margins
	real_bottomr = Vector2(board.position.x+board.scale.x/2, board.position.y+board.scale.y/2) + bottom_right_graph_margins
	real_topr = Vector2(real_bottomr.x, real_topl.y)
	real_bottoml = Vector2(real_topl.x, real_bottomr.y)
	
	
	# calculation of topl and bottomr.
	# if maximised // topl and bottomr are set to the boundaries of the board, much like real_topl and real_bottomr.
	# else // TBD
	if chart_parameters['maximised'] == true:
		topl = Vector2(board.position.x-board.scale.x/2, board.position.y-board.scale.y/2) + largest_point_size
		if largest_point_size != Vector2(0, 0):
			topl += Vector2(10, 10)
		
		bottomr = Vector2(board.position.x+board.scale.x/2, board.position.y+board.scale.y/2) - largest_point_size
		if largest_point_size != Vector2(0, 0):
			bottomr -= Vector2(10, 10)
	else:
		pass
	
	topr = Vector2(bottomr.x, topl.y)
	bottoml = Vector2(topl.x, bottomr.y)
	
	inner_topl = topl + largest_point_size
	inner_bottomr = bottomr - largest_point_size
	inner_topr = Vector2(topl.y, bottomr.x)
	inner_bottoml = Vector2(topl.x, bottomr.y)
	

func set_series(series_name, array):
	series_dict[series_name] = Series.new()
	series_dict[series_name].set_up(array)

func set_data(data = dataset):
	var list_of_keys = []
	
	if dataset != {}:
		for key in dataset:
			set_series(key, dataset[key])
			
			list_of_keys.append(key)
		
#			chart_parameters["x axes"][list_of_keys[0]] = [] #automatically setting the first series as the 'x-axis'. Just for the setup.
			chart_parameters["x axes"]["x"] = ["y", "y2"]
			chart_parameters["x axes"]["x2"] = []#"y3"]
			
#			if chart_parameters["x axes"].has(key) == false:
#				# adding it to the "main" y-axis
#				chart_parameters["y axes"][0].append(key)

		chart_parameters["y axes"].append(["y3"])
		
		for sublist_num in range(0, len(chart_parameters["y axes"])):
			
			# creating the same number of sublists in chart_parameters["y axis min max values"] as there are in chart_parameters["y axes"]. Each sublist represents a y axis. In the case of chart_parameters["y axis min max values"], each sublist contains the minimum and maximum values for the corresponding sublist in chart_parameters["y axes"], by index. Y axes are not named.
			# EX: chart_parameters['y axes'] = [['y1', 'y2'], ['y3']]
			# EX: chart_parameters["y axis min max values"] = [[0, 100], [0, 20]]
			chart_parameters["y axis min values"].append(null)
			chart_parameters["y axis max values"].append(null)
			
	else:
		no_data = true
	
	# Setting up a default title
	if list_of_keys.size() == 2:
		chart_parameters["title"]["text"] = list_of_keys[0] + " vs. " + list_of_keys[1]
	
	else:
		var loop = 0
		for series_name in list_of_keys:
			if loop != 0:
				chart_parameters["title"]["text"] += ", " + series_name
			else:
				chart_parameters["title"]["text"] += series_name
			
			loop += 1
	

## Returns a power of ten depending on the value (the value parameter is a range, meaning a bigger number subtracted by a smaller number). For example, if the value parameter is set to be anywhere from >0- <10, the function will return 10. If the value parameter is anywhere from >=10-99, the function will return 10.
func return_applicable_power_of_ten(value) -> float:
	# floats smaller than 1 not tested
	
	if value == 0:
		return 10**0
	
	var length_of_decimal_upon_sig_fig: float = 0.0 # for the power of ten. 0.123 will be 1 (or 10^-1). 0.08234 will be 2 (or 10^-2)
	var past_the_decimal = false
	
	if value < 1 and value > 0: # if the value is a decimal between 0 and 1
		for char in str(value):
			# if the iteration is past the decimal point in the string form
			if past_the_decimal:
				length_of_decimal_upon_sig_fig += 1.0
			
			# if the iteration is at the decimal point in the string form of the value
			if char == ".":
				past_the_decimal = true
		
		return 10.0 ** -(length_of_decimal_upon_sig_fig)
	
	if value > 0: # if the value is positive and not a decimal between 0 and 1
		return 10.0 ** (len(str(int(value))) - 1.0)
	
	if value > -1 and value < 0: # if the value is a decimal between 0 and -1
		for char in str(value):
			# if the iteration is past the decimal point in the string form
			if past_the_decimal:
				length_of_decimal_upon_sig_fig += 1.0
			
			# if the iteration is at the decimal point in the string form of the value
			if char == ".":
				past_the_decimal = true
		
		return -(10.0 ** -(length_of_decimal_upon_sig_fig))
	
	if value < 0: # if the value is negative and not a decimal between 0 and 1
		return -(10.0 ** (len(str(int(value))) - 1.0))
	
	return 10.0 ** 0.0

# setting the positions of vertical major gridlines, as well as the adjusted_max_values and adjusted_min_values
func vertical_major_gridlines():
	const LIST_OF_SCALE_OPTIONS = [1, 2, 2.5, 5]
	const POSSIBLE_NUMS_OF_GRIDLINES = [3, 4, 5]
	
	
	adjusted_max_values.clear()
	adjusted_min_values.clear()
	
	list_of_vertical_major_gridlines.clear()
	
	for i in range(0, len(chart_parameters["y axes"])):
		
		# if on the main y-axis
		if i == 0:
			# if the specified y axis' min and/or max values have been manually set
			if chart_parameters["y axis min values"][0] != null or chart_parameters["y axis max values"][0] != null:
				var min_value
				var max_value
				
				if chart_parameters["y axis min values"][0] != null:
					min_value = chart_parameters["y axis min values"][i]
				else:
					min_value = smallest_min_values[0]
				
				if chart_parameters["y axis max values"][0] != null:
					max_value = chart_parameters["y axis max values"][i]
				else:
					max_value = biggest_max_values[0]
				
				adjusted_min_values.append(min_value)
				adjusted_max_values.append(max_value)
				
				# if the scale has not been manually set, and the min and max values have been manually set
				if chart_parameters["vertical gridlines and ticks"]["major gridlines"]["scale"] == null:
					var auto_scale = (max_value - min_value) / 5
					
					for x in range(1, 6):
						list_of_vertical_major_gridlines.append(min_value + (auto_scale * x))
				
				# if the scale HAS been manually set, and the min and max values have also been manually set
				else:
					for x in range(1, floor((max_value - min_value) / chart_parameters["vertical gridlines and ticks"]["major gridlines"]["scale"]) + 1):
						list_of_vertical_major_gridlines.append(min_value + (chart_parameters["vertical gridlines and ticks"]["major gridlines"]["scale"] * x))
			
			# if ONLY the scale of the graph has been altered
			elif chart_parameters["vertical gridlines and ticks"]["major gridlines"]["scale"] != null:
				
				var custom_scale = chart_parameters["vertical gridlines and ticks"]["major gridlines"]["scale"]
				
				var min
				var max
				
				if smallest_min_values[i] < 0 and biggest_max_values[i] <= 0:
					min = -(custom_scale * ceil_floor(abs(smallest_min_values[i]) / custom_scale, true))
					max = 0
				elif smallest_min_values[i] >= 0 and biggest_max_values[i] > 0:
					min = 0
					max = custom_scale * ceil_floor(biggest_max_values[i] / custom_scale, true)
				else:
					min = -(custom_scale * ceil_floor(abs(smallest_min_values[i]) / custom_scale, true))
					max = custom_scale * ceil_floor(biggest_max_values[i] / custom_scale, true)
				
				# if the min value is negative and the max value is either negative or 0
				if smallest_min_values[i] < 0 and biggest_max_values[i] <= 0:
					adjusted_max_values.append(0)
					adjusted_min_values.append(min)
					
					for x in range(1, ceil_floor(abs(smallest_min_values[i]) / custom_scale, true) + 1 ):
						list_of_vertical_major_gridlines.append(-(x * custom_scale))
				
				# if the min value is larger or equal to 0 and the max value is larger than 0
				elif smallest_min_values[i] >=0 and biggest_max_values[i] > 0:
					adjusted_max_values.append(max)
					adjusted_min_values.append(0)
					
					for x in range(1, ceil_floor(biggest_max_values[i] / custom_scale, true) + 1 ):
						list_of_vertical_major_gridlines.append(x * custom_scale)
				
				# if min value is negative and the max value is positive
				else:
					adjusted_max_values.append(max)
					adjusted_min_values.append(min)
					
					for x in range(1, ceil_floor(abs(smallest_min_values[i]) / custom_scale, true) + 1 ):
						list_of_vertical_major_gridlines.append(-(x * custom_scale))
					
					for x in range(1, ceil_floor(biggest_max_values[i] / custom_scale, true) + 1 ):
						list_of_vertical_major_gridlines.append(x * custom_scale)
						
			
			# default graph, no other parameters
			else:
				
				var min
				var max
				
				var applicable_scale_option_found := false
				
				var two_scale_factors = [return_applicable_power_of_ten(biggest_max_values[i] - smallest_min_values[i])]
				two_scale_factors.append(two_scale_factors[0]/10.0)
				two_scale_factors.sort()
				
				var num_of_grids := 0
				
				for scale_factor in two_scale_factors:
					for scale_option in LIST_OF_SCALE_OPTIONS:
						num_of_grids = 0
						
						if smallest_min_values[i] < 0 and biggest_max_values[i] <= 0:
							num_of_grids = ceil_floor(abs(smallest_min_values[i]) / (scale_factor * scale_option), true)
						
						elif smallest_min_values[i] >= 0 and biggest_max_values[i] > 0:
							num_of_grids = ceil_floor(biggest_max_values[i] / (scale_factor * scale_option), true)
						
						else:
							num_of_grids += ceil_floor(abs(biggest_max_values[i]) / (scale_factor * scale_option), true) + 1 # for the 0
							num_of_grids += ceil_floor(abs(smallest_min_values[i]) / (scale_factor * scale_option), true)
						
						if POSSIBLE_NUMS_OF_GRIDLINES.has(num_of_grids):
						# if fit to y axes, set adjusted min/max to the scales. If not, fit the y axes to the values.
							if smallest_min_values[i] < 0 and biggest_max_values[i] <= 0:
								min = -(scale_factor * scale_option * num_of_grids)
								max = 0
							elif smallest_min_values[i] >= 0 and biggest_max_values[i] > 0:
								min = 0
								max = scale_factor * scale_option * num_of_grids
							else:
								min = -(scale_factor * scale_option * num_of_grids)
								max = scale_factor * scale_option * num_of_grids
							
							adjusted_max_values.append(max)
							adjusted_min_values.append(min)
							
							# if the min value is negative and the max value is either negative or 0
							if smallest_min_values[i] < 0 and biggest_max_values[i] <= 0:
								for x in range(1, num_of_grids + 1 ):
									list_of_vertical_major_gridlines.append(-(x * scale_factor * scale_option))
							
							# if the min value is larger or equal to 0 and the max value is larger than 0
							elif smallest_min_values[i] >=0 and biggest_max_values[i] > 0:
								for x in range(1, num_of_grids + 1 ):
									list_of_vertical_major_gridlines.append(x * scale_factor * scale_option)
							
							# if min value is negative and the max value is positive
							else:
								for x in range(1, ceil_floor(abs(smallest_min_values[i]) / (scale_factor * scale_option), true) + 1 ):
									list_of_vertical_major_gridlines.append(0)
									list_of_vertical_major_gridlines.append(-(x * scale_factor * scale_option))
								
								for x in range(1, ceil_floor(abs(biggest_max_values[i]) / (scale_factor * scale_option), true) + 1 ):
									list_of_vertical_major_gridlines.append(x * scale_factor * scale_option)
							
							applicable_scale_option_found = true
							break
					
					if applicable_scale_option_found:
						break
			
		# if not on the main y-axis
		else:
			
			# if the min and max values have been set
			if chart_parameters["y axis min values"][i] != null or chart_parameters["y axis max values"][i] != null:
				var min_value
				var max_value
				
				if chart_parameters["y axis min values"][i] != null:
					min_value = chart_parameters["y axis min values"][i]
				else:
					min_value = smallest_min_values[i]
				
				if chart_parameters["y axis max values"][i] != null:
					max_value = chart_parameters["y axis max values"][i]
				else:
					max_value = biggest_max_values[i]
				
				adjusted_min_values.append(min_value)
				adjusted_max_values.append(max_value)
				
			# default settings
			else:
				
				var min
				var max
				
				var applicable_scale_option_found := false
				
				var num_of_grids = len(list_of_vertical_major_gridlines)
				var three_scale_factors = [return_applicable_power_of_ten((biggest_max_values[i] - smallest_min_values[i]) / num_of_grids)]
				three_scale_factors.append(three_scale_factors[0]/10)
				three_scale_factors.append(three_scale_factors[0]*10.0)
				three_scale_factors.sort()
				
				
				for scale_factor in three_scale_factors:
					for scale_option in LIST_OF_SCALE_OPTIONS:
						
						var minmax_rounded_to_scale = [ceil_floor_snapped(smallest_min_values[i], scale_option * scale_factor, false), ceil_floor_snapped(biggest_max_values[i], scale_option * scale_factor, true)]
						
						var matching_num_of_grids := 0
						
						if smallest_min_values[i] < 0 and biggest_max_values[i] <= 0:
							matching_num_of_grids = abs(minmax_rounded_to_scale[0] / (scale_option * scale_factor))
						
						elif smallest_min_values[i] >= 0 and biggest_max_values[i] > 0:
							matching_num_of_grids = minmax_rounded_to_scale[1] / (scale_option * scale_factor)
						
						else:
							matching_num_of_grids += abs(minmax_rounded_to_scale[0] / (scale_option * scale_factor))
							matching_num_of_grids += minmax_rounded_to_scale[1] / (scale_option * scale_factor)
						if num_of_grids >= matching_num_of_grids:
							if smallest_min_values[i] < 0 and biggest_max_values[i] <= 0:
								min = -(scale_factor * scale_option * num_of_grids)
								max = 0
							elif smallest_min_values[i] >= 0 and biggest_max_values[i] > 0:
								min = 0
								max = scale_factor * scale_option * num_of_grids
							else:
								min = minmax_rounded_to_scale[0] - ceil_floor_snapped((num_of_grids - matching_num_of_grids) / 2, scale_option * scale_factor, false)
								max = minmax_rounded_to_scale[1] + ceil_floor_snapped((num_of_grids - matching_num_of_grids) / 2, scale_option * scale_factor, true)
							
							adjusted_max_values.append(max)
							adjusted_min_values.append(min)
							
							applicable_scale_option_found = true
							break
					
					if applicable_scale_option_found:
						break
	
	list_of_vertical_major_gridlines.sort()

func vertical_minor_gridlines():
	list_of_vertical_minor_gridlines.clear()
	
	if chart_parameters["vertical gridlines and ticks"]["minor gridlines"]["draw"]:
		
		# if the number of major gridlines is greater than 0
		if len(list_of_vertical_major_gridlines) > 0:
			# if the number of minor gridlines is set to be greater than 0
			if chart_parameters["vertical gridlines and ticks"]["minor gridlines"]["count"] > 0:
				var space_between_each_gridline = list_of_vertical_major_gridlines[1] - list_of_vertical_major_gridlines[0]
				
				var interval = space_between_each_gridline / (chart_parameters["vertical gridlines and ticks"]["minor gridlines"]["count"] + 1)
				
				# recording the y values of the minor gridlines
				for maj_gridline in list_of_vertical_major_gridlines:
					for x in range(1, chart_parameters["vertical gridlines and ticks"]["minor gridlines"]["count"] + 1):
						
						# if the minor gridline is less than the max value
						if (maj_gridline + (interval * x)) < adjusted_max_values[0]:
							list_of_vertical_minor_gridlines.append(maj_gridline + (interval * x))
				
				# adding the y values of the minor gridlines below the first major v gridline
				for x in range(1, chart_parameters["vertical gridlines and ticks"]["minor gridlines"]["count"] + 1):
					list_of_vertical_minor_gridlines.append(list_of_vertical_major_gridlines[0] - (interval * x))
		
	list_of_vertical_minor_gridlines.sort()

func horizontal_major_gridlines():
	list_of_horizontal_major_gridlines.clear()
	
	var first_x_axis : String
	var first_x_axis_found : bool = false
	
	var is_min_altered = false
	var is_max_altered = false
	
	# record manually adjusted max values
	for key in chart_parameters["x axis max values"]:
		is_max_altered = true
		horizontal_max_values[key] = chart_parameters["x axis max values"][key]
	# record manually adjusted min values
	for key in chart_parameters["x axis min values"]:
		is_min_altered = true
		horizontal_min_values[key] = chart_parameters["x axis min values"][key]
	
	# if there are max values that have not been manually adjusted (i.e. they are still null), automatically find the max values.
	for key in horizontal_max_values:
		if chart_parameters["main x axis"] == null:
			if first_x_axis_found == false:
				first_x_axis = key
				first_x_axis_found = true
		else:
			first_x_axis = chart_parameters["main x axis"]
			first_x_axis_found = true
		
		if horizontal_max_values[key] == null:
			horizontal_max_values[key] = series_dict[key].find_max_value(series_dict[key].valid_values)
	# if there are min values that have not been manually adjusted (i.e. they are still null), automatically find the min values.
	for key in horizontal_min_values:
		if horizontal_min_values[key] == null:
			horizontal_min_values[key] = series_dict[key].find_min_value(series_dict[key].valid_values)
	
	# if the min or max values have been altered
	if is_max_altered == true or is_min_altered == true:
		var num_of_grids = 5
		
		
	# if the min or max values have NOT been altered, prompting automatic behaviour
	else:
		list_of_horizontal_major_gridlines.append(horizontal_min_values[first_x_axis])
		
		const LIST_OF_SCALE_OPTIONS = [1, 2, 2.5, 5]
		const POSSIBLE_NUMS_OF_GRIDLINES = [3, 4, 5]
		
		var applicable_scale_option_found := false
		
		var two_scale_factors = [return_applicable_power_of_ten(horizontal_max_values[first_x_axis] - horizontal_min_values[first_x_axis])]
		two_scale_factors.append(two_scale_factors[0]/10.0)
		two_scale_factors.sort()
		
		var num_of_grids := 0
				
		for scale_factor in two_scale_factors:
			for scale_option in LIST_OF_SCALE_OPTIONS:
				num_of_grids = 0
				
				if horizontal_min_values[first_x_axis] < 0 and horizontal_max_values[first_x_axis] <= 0:
					num_of_grids = ceil_floor(abs(horizontal_min_values[first_x_axis]) / (scale_factor * scale_option), false)
				
				elif horizontal_min_values[first_x_axis] >= 0 and horizontal_max_values[first_x_axis] > 0:
					num_of_grids = ceil_floor(horizontal_max_values[first_x_axis] / (scale_factor * scale_option), false)
				
				else:
					num_of_grids += ceil_floor(abs(horizontal_max_values[first_x_axis]) / (scale_factor * scale_option), false) + 1 # for the zero
					num_of_grids += ceil_floor(abs(horizontal_min_values[first_x_axis]) / (scale_factor * scale_option), false)
				
				if POSSIBLE_NUMS_OF_GRIDLINES.has(num_of_grids):
					# if the min value is negative and the max value is either negative or 0
					if horizontal_min_values[first_x_axis] < 0 and horizontal_max_values[first_x_axis] <= 0:
						for x in range(1, num_of_grids + 1 ):
							list_of_horizontal_major_gridlines.append(-(x * scale_factor * scale_option))
					
					# if the min value is larger or equal to 0 and the max value is larger than 0
					elif horizontal_min_values[first_x_axis] >=0 and horizontal_max_values[first_x_axis] > 0:
						for x in range(1, num_of_grids + 1 ):
							list_of_horizontal_major_gridlines.append(x * scale_factor * scale_option)
					
					# if min value is negative and the max value is positive
					else:
						for x in range(1, ceil_floor(abs(horizontal_min_values[first_x_axis]) / (scale_factor * scale_option), false) + 1 ):
							list_of_horizontal_major_gridlines.append(0)
							list_of_horizontal_major_gridlines.append(-(x * scale_factor * scale_option))
						
						for x in range(1, ceil_floor(abs(horizontal_max_values[first_x_axis]) / (scale_factor * scale_option), false) + 1 ):
							list_of_horizontal_major_gridlines.append(x * scale_factor * scale_option)
					applicable_scale_option_found = true
					break
			
			if applicable_scale_option_found:
				break
	
	main_x_axis = first_x_axis

func horizontal_minor_gridlines():
	list_of_horizontal_minor_gridlines.clear()
	
	if chart_parameters["horizontal gridlines and ticks"]["minor gridlines"]["draw"]:
	
		# if the number of major gridlines is greater than 0
		if len(list_of_horizontal_major_gridlines) > 0:
			# if the number of minor gridlines is set to be greater than 0
			if chart_parameters["horizontal gridlines and ticks"]["minor gridlines"]["count"] > 0:
				var total_spacing = list_of_horizontal_major_gridlines[1] - list_of_horizontal_major_gridlines[0]
				var spacing = total_spacing / (chart_parameters["horizontal gridlines and ticks"]["minor gridlines"]["count"] + 1)
				
				for gridline in list_of_horizontal_major_gridlines:
					for i in range(1, chart_parameters["horizontal gridlines and ticks"]["minor gridlines"]["count"]+1):
						
						# if the minor gridline is less than the max value
						if (gridline + (spacing * i)) < horizontal_max_values[main_x_axis]:
							list_of_horizontal_minor_gridlines.append(gridline + (spacing * i))
						
	
	list_of_horizontal_minor_gridlines.sort()


func update_functional_values():
	
	# if there is a newly added series that has not been added to any y-axis, add that series to the main y-axis in chart_parameters
	for series_name in series_dict:
		if return_sublists_as_list(chart_parameters["y axes"]).has(series_name) == false:
			if chart_parameters["x axes"].has(series_name) == false:
				chart_parameters["y axes"][0].append(series_name)
	
	# if there's an empty sublist, erase it
	for sublist in chart_parameters["y axes"]:
		if sublist.is_empty():
			chart_parameters["y axes"].erase(sublist)
	
	# if the x axis min value is set to null, erase it. It's invalid. See chart_parameters["x axis min values"].
	for key in chart_parameters["x axis min values"]:
		if chart_parameters["x axis min values"][key] == null:
			chart_parameters["x axis min values"].erase(key)
	
	# if the x axis max value is set to null, erase it. It's invalid. See chart_parameters["x axis max values"].
	for key in chart_parameters["x axis max values"]:
		if chart_parameters["x axis max values"][key] == null:
			chart_parameters["x axis max values"].erase(key)
	
	# adding x axes as keys to horizontal_max_values and horizontal_min_values
	horizontal_max_values.clear()
	horizontal_min_values.clear()
	for x_axis in chart_parameters["x axes"]:
		horizontal_max_values[x_axis] = null
		horizontal_min_values[x_axis] = null
	
	# if there's only one x-axis, assign all other series to that x-axis.
	if chart_parameters["x axes"].size() == 1:
		for axis in chart_parameters["x axes"]:
			for seri in series_dict:
				if seri != axis:
					chart_parameters["x axes"][axis].append(seri)
	
	# otherwise...
	else:
		
		# below: automated behaviour involving automatically assigning a series to an x-axis matching in length, if applicable. We can't have y-axis series not being linked with an x-axis.
		for series_key in series_dict: # for each series
			if series_key not in chart_parameters["x axes"]: # if the specified series is not an x axis
				if series_key not in return_list_of_values_from_dictionary_lists(chart_parameters["x axes"]): # if the specified series is not linked with an x-axis
					var series_length = len(series_dict[series_key].series)
					var matching_length_x_axis = ""
					
					# finding an x_axis with the same amount of items as the specified series
					for axis in chart_parameters["x axes"]:
						if len(series_dict[axis].series) == series_length:
							matching_length_x_axis = axis
					
					# if there is a matching_x_axis, link the specified series with it
					if matching_length_x_axis != "":
						chart_parameters["x axes"][matching_length_x_axis].append(series_key)
					
					# if not, add the specified series to the x_axis with the smallest amount of linked series
					else:
						var shortest_axis = ""
						var shortest_axis_value = 0
						
						var loop = 0
						
						for axis in chart_parameters["x axes"]:
							if loop != 0:
								if len(chart_parameters["x axes"][axis]) < shortest_axis_value:
									shortest_axis = axis
									shortest_axis_value = len(chart_parameters["x axes"][axis])
							else:
								shortest_axis = axis
								shortest_axis_value = len(chart_parameters["x axes"][axis])
						
						chart_parameters["x axes"][shortest_axis].append(series_key)

	var max_values = []
	var min_values = []
	
	var point_sizes = []
	var point_availability = false
	
	# for each series...
	for key in series_dict:
		
		# if the series is not an x-axis
		if chart_parameters["x axes"].has(key) == false:
			if series_dict[key].valid_series == true: # if the specified series is a numerical series
				if series_dict[key].treat_as_text != true:
					point_sizes.append(series_dict[key].series_parameters["points"]["point size"])
					
					# if the series is set to have points - drawn markers
					if series_dict[key].series_parameters["points"]["plot points"] == true:
						point_availability = true
	
	var loop = 0
	for sublist in chart_parameters["y axes"]:
		max_values.append([])
		min_values.append([])
		
		var min_value_has_been_manually_altered = false
		var max_value_has_been_manually_altered = false
		# if the min and max values for that y axis are not set (thus prompting automatic behaviour)
		if chart_parameters["y axis min values"][loop] != null:
			min_value_has_been_manually_altered = true
		
		if chart_parameters["y axis max values"][loop] != null:
			max_value_has_been_manually_altered = true
			
		for series_name in sublist:
			
			if max_value_has_been_manually_altered:
				max_values[loop].append(chart_parameters["y axis max values"][loop])
			else:
				max_values[loop].append(series_dict[series_name].find_max_value(series_dict[series_name].series.slice(0, len(series_dict[find_key_from_dictionary_list(series_name, chart_parameters["x axes"])].series))))
			
			if min_value_has_been_manually_altered:
				min_values[loop].append(chart_parameters["y axis min max values"][loop][0])
			else:
				min_values[loop].append(series_dict[series_name].find_min_value(series_dict[series_name].series.slice(0, len(series_dict[find_key_from_dictionary_list(series_name, chart_parameters["x axes"])].series))))
		
		loop += 1
	
	point_sizes.sort()
	max_values = return_with_sorted_sublists(max_values)
	min_values = return_with_sorted_sublists(min_values)
	
	# if the series is set to have points, set the largest_point_size (used for drawing margins - you can't draw circular points outside of the workspace, now can you?)
	if point_availability:
		largest_point_size = point_sizes.back()
	else:
		largest_point_size = Vector2(0, 0)
	
	for sublist in max_values:
		biggest_max_values.append(sublist.back())
	
	# if all the values of a series is positive, then the minimum value is automatically 0
	for sublist in min_values:
		smallest_min_values.append(sublist[0])
	
	vertical_major_gridlines()
	vertical_minor_gridlines()
	horizontal_major_gridlines()
	horizontal_minor_gridlines()


func plot_points(series_class, list, linked_x_axis, x_axis_position, linked_y_axis: int) -> Array: #plotting the points of a singular line
	var xpos
	var ypos
	
	var list_of_points = []
	
	var loop = x_axis_position
	
	if series_class.valid_series: # if the selected series is a valid series
		if series_class.treat_as_text != true:
			for point in list:
				if point != null:
					if loop < len(series_dict[linked_x_axis].valid_values):
						xpos = inner_topl.x + (((inner_bottomr.x - inner_topl.x) / (horizontal_max_values[linked_x_axis] - horizontal_min_values[linked_x_axis])) * (series_dict[linked_x_axis].valid_values[loop] - horizontal_min_values[linked_x_axis]))
#						xpos = topl.x + ((bottomr.x - topl.x) / (series_dict[linked_x_axis].find_range(series_dict[linked_x_axis].valid_values)) * (series_dict[linked_x_axis].valid_values[loop] - series_dict[linked_x_axis].find_min_value(series_dict[linked_x_axis].valid_values))) # the horizontal distance of the workspace divided by the (x??) range multiplied by the value (?? Are you sure about the range? What about the range of the x-axis?)
						ypos = bottomr.y - ((bottomr.y - topl.y) / (adjusted_max_values[linked_y_axis]-adjusted_min_values[linked_y_axis]) * (point - adjusted_min_values[linked_y_axis]))
#						ypos = bottomr.y - ((bottomr.y - topl.y) / (biggest_max_values[linked_y_axis]-smallest_min_values[linked_y_axis]) * (point - smallest_min_values[linked_y_axis])) # the vertical distance of the workspace divided by the y-axes range multiplied by the value
					
						list_of_points.append(Vector2(xpos, ypos))
				
				loop += 1

		return list_of_points
	
	return [false]

func update_graph():
	# if the line graph has data
	if !no_data:
		lines_to_draw = {}
		
		update_functional_values()
		
		set_workspace()
		
		set_labels()
		
		# !! Below: Calculating the positions of the lines
		#creating a list for every key
		for key in series_dict:
			if chart_parameters["x axes"].has(key) == false: # if the specified series is not an x-axis
				lines_to_draw[key] = []
		
		# appending lines to each series
		for key in series_dict:
			if chart_parameters["x axes"].has(key) == false: # if the specified series is not an x-axis
				var selected_x_axis = find_key_from_dictionary_list(key, chart_parameters["x axes"]) #finding the linked x axis for this y axis
				
				if series_dict[key].series_parameters['ignore void values'] == false:
					var lines_in_series = [[]] # list of lines in y-axis
					var loop = 0
					for value in series_dict[key].series:
						if value != null:
							lines_in_series[loop].append(value)
						else:
							lines_in_series[loop].append(value)
							# Below, the code is explicitly to prevent the code from creating two or more empty sublists in a row. If there's already an empty sublist, no need to create a new one, right?
							if lines_in_series[loop] != []:
								lines_in_series.append([])
								loop += 1
					
					loop = 0
					var list_index = 0
					for list in lines_in_series:
						
						if list != []:
							lines_to_draw[key].append(plot_points(series_dict[key], list, selected_x_axis, loop, return_sublist_index_from_sublist_value(key, chart_parameters["y axes"])))
						
						loop += len(lines_in_series[list_index])
						list_index += 1
				
				else: # if "ignore void values" is set to true, therefore plot_points will just return a singular, connected line/list of points for the _draw() function to draw.
					lines_to_draw[key].append(plot_points(series_dict[key], series_dict[key].valid_values, selected_x_axis, 0, return_sublist_index_from_sublist_value(key, chart_parameters["y axes"])))
		
		# queues the activation of the _draw() function
		queue_redraw()
	
	# if dataset has no data
	else:
		set_workspace()
	
		$MarginContainer.size = real_bottomr - real_topl
		$MarginContainer.position = topl
	
		$MarginContainer/VBoxContainer.alignment = $MarginContainer/VBoxContainer.ALIGNMENT_CENTER
		Title.text = "[center][b]No Data[/b][/center]"
		Title.add_theme_font_size_override("bold_font_size", 40)
		Title.add_theme_color_override("default_color", "646464")


func set_Title():

	# if the chart_parameters["title"]["font"] is empty, then automatically set the normal font to DroidSans (default_font)
	if chart_parameters["title"]["font"] == "":
		if current_font["title"] != default_font:
			current_font["title"] = default_font
		
		chart_parameters["title"]["font"] = default_font
		Title.add_theme_font_override("normal_font", load(chart_parameters["title"]["font"]))
	
	# Below: loading the new font if the user has decided to change the font. The below code only activates if the font is different, thus preventing from loading an already-loaded font every frame/time the graph is updated.
	if current_font["title"] != chart_parameters["title"]["font"]:
		Title.add_theme_font_override("normal_font", load(chart_parameters["title"]["font"]))
		current_font["title"] = chart_parameters["title"]["font"]
	
	if chart_parameters["title"]["custom bold font"] != "":
		if current_font_bold["title"] != chart_parameters["title"]["custom bold font"]:
			Title.add_theme_font_override("bold_font", load(chart_parameters["title"]["custom bold font"]))
			current_font_bold["title"] = chart_parameters["title"]["custom bold font"]
	
	if chart_parameters["title"]["custom italic font"] != "":
		if current_font_italics["title"] != chart_parameters["title"]["custom italic font"]:
			Title.add_theme_font_override("italics_font", load(chart_parameters["title"]["custom italic font"]))
			
			current_font_italics["title"] = chart_parameters["title"]["custom italic font"]
	
	if chart_parameters["title"]["custom bold italic font"] != "":
		if current_font_bold_italics["title"] != chart_parameters["title"]["custom bold italic font"]:
			Title.add_theme_font_override("bold_italics_font", load(chart_parameters["title"]["custom italic font"]))
			
			current_font_bold_italics["title"] = chart_parameters["title"]["custom bold italic font"]


	var title_text = ""
	var text_style = ""
	
	# Setting up text
	if chart_parameters["title"]["bold"] == true and chart_parameters["title"]["italic"] == true:
		title_text = "[i][b]" + chart_parameters["title"]["text"] + "[/b][/i]"
		text_style = "bold_italics"

	# If the Title is set to be bolded
	elif chart_parameters["title"]["bold"] == true:
		title_text = "[b]" + chart_parameters["title"]["text"] + "[/b]"
		text_style = "bold"
	
	elif chart_parameters["title"]["italic"] == true:
		title_text = "[i]" + chart_parameters["title"]["text"] + "[/i]"
		text_style = "italics"

	# If the Title is not set to be bolded or italicized
	else:
		title_text = chart_parameters["title"]["text"]
		text_style = "normal"
	
	Title.text = "[" + chart_parameters["title"]["alignment options"][  chart_parameters["title"]["selected alignment"]  ] + "]" + title_text + "[/" + chart_parameters["title"]["alignment options"][  chart_parameters["title"]["selected alignment"]  ] + "]"


	# Setting font size
	if chart_parameters["title"]["size"] == -1: #-1 means that the size will be automatically set.
		Title.add_theme_font_size_override(text_style + "_font_size", clamp_minimum((real_bottomr.y-real_topl.y)/18, 12))
	else:
		Title.add_theme_font_size_override(text_style + "_font_size", chart_parameters["title"]["size"])
	
	# setting up the title_rect, basically a makeshift Area2D. Used later to ensure any labels aren't drawn within the boundaries of the title.
	title_rect = [Title.global_position, Title.global_position + Title.get_theme_font(text_style + "_font").get_string_size(chart_parameters["title"]["text"])]
	
	# Setting up the colour
	Title.add_theme_color_override("default_color", chart_parameters["title"]["colour"])
	
	
	# if the graph is set to draw an outline for the title
	if chart_parameters["title"]["draw outline"]:
		Title.add_theme_constant_override("outline_size", chart_parameters["title"]["outline weight"])
		Title.add_theme_color_override("font_outline_color", chart_parameters["title"]["outline colour"])

func v_label_handler():
	# matching the number of vertical axis labels with the number of gridlines
	if $VLabels.get_child_count() > (len(list_of_vertical_major_gridlines) + 2) * chart_parameters["x axes"].size():
#		for i in range(((len(list_of_vertical_major_gridlines) + 2) * chart_parameters["x axes"].size()) * chart_parameters["x axes"].size(), $VLabels.get_child_count()):
#			$VLabels.get_child(i).queue_free()
		for n in $VLabels.get_children():
			$VLabels.remove_child(n)
			n.queue_free()

		for i in (len(list_of_vertical_major_gridlines) + 2) * chart_parameters["x axes"].size():
			var n_label = RichTextLabel.new()
			$VLabels.add_child(n_label)
	
	elif $VLabels.get_child_count() < ((len(list_of_vertical_major_gridlines) + 2) * chart_parameters["x axes"].size()):
		for i in range($VLabels.get_child_count(), ((len(list_of_vertical_major_gridlines) + 2) * chart_parameters["x axes"].size())):
			var n_label = RichTextLabel.new()
			$VLabels.add_child(n_label)
	
	# the space (in pixels) between each graph gridline.
	var space_between_each_gridline = (bottomr.y - ((bottomr.y-topl.y) * (list_of_vertical_major_gridlines[1]-adjusted_min_values[0])/(adjusted_max_values[0]-adjusted_min_values[0]))) - (bottomr.y - ((bottomr.y-topl.y) * (list_of_vertical_major_gridlines[0]-adjusted_min_values[0])/(adjusted_max_values[0]-adjusted_min_values[0])))
	
	# the space between the bottom of the graph (the minimum value) and the first gridline.
	var space_between_first_gridline_and_min = bottomr.y - ((bottomr.y-topl.y) * (list_of_vertical_major_gridlines[0]-adjusted_min_values[0])/(adjusted_max_values[0]-adjusted_min_values[0]))
	
	# the space between the top of the graph (the maximum value) and the last gridline.
	var space_between_last_gridline_and_max = (bottomr.y - ((bottomr.y-topl.y) * (list_of_vertical_major_gridlines[0]-adjusted_min_values[0])/(adjusted_max_values[0]-adjusted_min_values[0]))) - topl.y
	
	var test_font = FontFile.new()
	test_font.load_dynamic_font(default_font)
	
	# Untested code below!
	# Explanation: Are there labels every 1 gridline? Every 2 gridlines? Every 3? 
	var frequency_of_labels = clamp_minimum(ceil_floor_snapped(test_font.get_string_size("Hello world!", 0, -1, chart_parameters["vertical axis labels"]["size"]).y, space_between_each_gridline, true), 1)
	
	# the index of the gridline where there is enough space between the gridline and the bottom edge of the graph (minimum value) to draw text that won't be cut off. This is the index of the gridline where we'll begin drawing labels.
	var starting_gridline = ceil_floor(test_font.get_string_size("Hello world!", 0, -1, chart_parameters["vertical axis labels"]["size"]).y / space_between_first_gridline_and_min, true)
	
	# the index of the last gridline where there is enough space between the gridline and the top edge of the graph to draw the label so that text won't be cut off. This is the index where we'll stop drawing labels.
	var ending_gridline = len(list_of_vertical_major_gridlines) -  ceil_floor(test_font.get_string_size("Hello world!", 0, -1, chart_parameters["vertical axis labels"]["size"]).y / space_between_last_gridline_and_max, true)
	
	var label_font = null
	# if the user has changed the font // label_font is no longer null, the new font is recorded in current_font.
	if current_font["vertical axis labels"] != chart_parameters["vertical axis labels"]["font"]:
		current_font["vertical axis labels"] = chart_parameters["vertical axis labels"]["font"]
		label_font = chart_parameters["vertical axis labels"]["font"]
	
	var list_of_all_label_values = []
	for x in range(0, len(adjusted_max_values)):
		if x != 0:
			list_of_all_label_values.append([])
			for i in range(0, len(list_of_vertical_major_gridlines)):
				list_of_all_label_values[x].append(adjusted_min_values[x] + (adjusted_max_values[x] - adjusted_min_values[x]) * (list_of_vertical_major_gridlines[i] / (adjusted_max_values[0]-adjusted_min_values[0])))
			
			list_of_all_label_values[x].append(adjusted_min_values[x])
			list_of_all_label_values[x].append(adjusted_max_values[x])
			list_of_all_label_values[x].sort()
		else:
			list_of_all_label_values.append(list_of_vertical_major_gridlines.duplicate())
			list_of_all_label_values[0].append(adjusted_min_values[0])
			list_of_all_label_values[0].append(adjusted_max_values[0])
			list_of_all_label_values[0].sort()
	
	var side := true #true is left, false is right
	var child_num := 0 #iteration value, used to call get_child() from $VLabels
	var sublist_iteration_value := 0
	var x_offset := 0
	var widest_x_offset_of_axis := 0
	
	for sublist_num in len(list_of_all_label_values):
		sublist_iteration_value = 0
		
		for value in list_of_all_label_values[sublist_num]:
			$VLabels.get_child(child_num).autowrap_mode = TextServer.AUTOWRAP_OFF
			
			$VLabels.get_child(child_num).visible = chart_parameters["vertical axis labels"]["visible"]
			$VLabels.get_child(child_num).text = str(snapped(value, chart_parameters["vertical axis labels"]["labelled decimal precision (power of ten)"]))
			
			# outlines
			if chart_parameters["vertical axis labels"]["draw outline"]:
				$VLabels.get_child(child_num).add_theme_constant_override("outline_size", chart_parameters["vertical axis labels"]["outline weight"])
				$VLabels.get_child(child_num).add_theme_color_override("font_outline_color", chart_parameters["vertical axis labels"]["outline colour"])
			else:
				$VLabels.get_child(child_num).add_theme_constant_override("outline_size", 0)
			
			# if the user has changed the font // load a new font in theme_font_override
			if label_font != null:
				$VLabels.get_child(child_num).add_theme_font_override("normal_font", load(label_font))
			
			# font size
			$VLabels.get_child(child_num).add_theme_font_size_override("normal_font_size", chart_parameters["vertical axis labels"]["size"])
			
			# colour
			$VLabels.get_child(child_num).add_theme_color_override("default_color", chart_parameters["vertical axis labels"]["colour"])
			
			
			$VLabels.get_child(child_num).custom_minimum_size = $VLabels.get_child(child_num).get_theme_font("normal_font").get_string_size($VLabels.get_child(child_num).text, 0, -1, chart_parameters["vertical axis labels"]["size"])
			
			# the width 'widest' label in this axis. This value is added to the overall x_offset
			if $VLabels.get_child(child_num).custom_minimum_size.x > widest_x_offset_of_axis:
				widest_x_offset_of_axis = $VLabels.get_child(child_num).custom_minimum_size.x
			
			
			if sublist_iteration_value < starting_gridline:
				if sublist_iteration_value != 0:
					$VLabels.get_child(child_num).visible = false
			elif sublist_iteration_value > ending_gridline:
				if sublist_iteration_value != len(list_of_all_label_values[sublist_num]) -1:
					$VLabels.get_child(child_num).visible = false
			else:
				if fmod((sublist_iteration_value - starting_gridline), frequency_of_labels) != 0:
					$VLabels.get_child(child_num).visible = false
			
			var x_pos
			if side:
				x_pos = topl.x + x_offset
			else:
				x_pos = bottomr.x - $VLabels.get_child(child_num).custom_minimum_size.x - x_offset
			
			$VLabels.get_child(child_num).position = Vector2(x_pos, bottomr.y - ((bottomr.y-topl.y) * (value-adjusted_min_values[sublist_num])/(adjusted_max_values[sublist_num]-adjusted_min_values[sublist_num]))) + Vector2(0, 2)
			$VLabels.get_child(child_num).position = $VLabels.get_child(child_num).position.clamp(topl, bottomr - Vector2(0, $VLabels.get_child(child_num).custom_minimum_size.y))
			
			if chart_parameters["maximised"]:
				# if the specified richtextlabel is not inside the boundaries of the title 
				# don't forget the subtitle!
				if rect_inside_another_rect($VLabels.get_child(child_num).position, $VLabels.get_child(child_num).position + $VLabels.get_child(child_num).custom_minimum_size, title_rect[0], title_rect[1]):
					$VLabels.get_child(child_num).visible = false
			
			child_num += 1
			sublist_iteration_value += 1
		
		side = !side
		if side:
			x_offset += widest_x_offset_of_axis
			widest_x_offset_of_axis = 0


func set_labels():
	$MarginContainer.size = real_bottomr - real_topl
	$MarginContainer.position = topl
	
	for direction in chart_parameters["graph inner margins"]:
		$MarginContainer.add_theme_constant_override("margin_" + direction, chart_parameters["graph inner margins"][direction])
	
	set_Title()
	v_label_handler()

func _draw():
	
	# drawing the inner graph boundary
	if chart_parameters["maximised"] != true:
		if chart_parameters["inner graph boundary"]["draw"] == true:
			draw_line(topl, topr, chart_parameters["inner graph boundary"]["colour"], chart_parameters["inner graph boundary"]["weight"], true)
			draw_line(topr, bottomr, chart_parameters["inner graph boundary"]["colour"], chart_parameters["inner graph boundary"]["weight"], true)
			draw_line(topl, bottoml, chart_parameters["inner graph boundary"]["colour"], chart_parameters["inner graph boundary"]["weight"], true)
			draw_line(bottoml, bottomr, chart_parameters["inner graph boundary"]["colour"], chart_parameters["inner graph boundary"]["weight"], true)
	
	# drawing the vertical minor gridlines
	for gridline in list_of_vertical_minor_gridlines:
		var ypos = bottomr.y - ((bottomr.y-topl.y) * (gridline-adjusted_min_values[0])/(adjusted_max_values[0]-adjusted_min_values[0]))
		
		draw_line(Vector2(topl.x, ypos), Vector2(topr.x, ypos), chart_parameters["vertical gridlines and ticks"]["minor gridlines"]["colour"], chart_parameters["vertical gridlines and ticks"]["minor gridlines"]['weight'], true)
	
	# drawing the horizontal minor gridlines
	for gridline in list_of_horizontal_minor_gridlines:
		var xpos = inner_topl.x + ((inner_bottomr.x-inner_topl.x) * (gridline-horizontal_min_values[main_x_axis])/(horizontal_max_values[main_x_axis] - horizontal_min_values[main_x_axis]))
		
		draw_line(Vector2(xpos, topl.y), Vector2(xpos, bottomr.y), chart_parameters["horizontal gridlines and ticks"]["minor gridlines"]["colour"], chart_parameters["horizontal gridlines and ticks"]["minor gridlines"]["weight"], true)
	
	# drawing the vertical major gridlines
	for gridline in list_of_vertical_major_gridlines:
		var ypos = bottomr.y - ((bottomr.y-topl.y) * (gridline-adjusted_min_values[0])/(adjusted_max_values[0]-adjusted_min_values[0]))
		
		if ypos <= topl.y:
			if ypos < topl.y:
				print('uh oh it happened')
			if chart_parameters["maximised"]:
				break
		
		draw_line(Vector2(topl.x, ypos), Vector2(topr.x, ypos), chart_parameters["vertical gridlines and ticks"]["major gridlines"]["colour"], chart_parameters["vertical gridlines and ticks"]["major gridlines"]['weight'], true)
	
	# drawing the horizontal major gridlines
	for gridline in list_of_horizontal_major_gridlines:
		var xpos = inner_topl.x + ((inner_bottomr.x-inner_topl.x) * (gridline-horizontal_min_values[main_x_axis])/(horizontal_max_values[main_x_axis]-horizontal_min_values[main_x_axis]))
		
		draw_line(Vector2(xpos, topl.y), Vector2(xpos, bottomr.y), chart_parameters["horizontal gridlines and ticks"]["major gridlines"]["colour"], chart_parameters["horizontal gridlines and ticks"]["major gridlines"]['weight'], true)
	
	# drawing the lines
	var loop = 0
	
	for key in lines_to_draw:
		for line in lines_to_draw[key]:
			loop = 0
			for point in line:
				if loop != 0:
					draw_line(line[loop-1], line[loop], series_dict[key].series_parameters['line']['colour'], series_dict[key].series_parameters['line']['weight'], true)
				loop += 1

# TODO:
	# two types of graph resizing: normal resize and pixel scale resize
	# normal resize resizes the drawing board, and the graph will automatically make corrections to proportions, labels, positions, et cetera
	# pixel scale resize will scale the RESOLUTION of the graph by altering the thickness of the lines, size of text, et cetera, so it isn't like resizing the resolution of an image exactly, but it will (hopefully) produce the same effect
