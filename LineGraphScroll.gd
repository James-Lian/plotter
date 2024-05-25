extends ScrollContainer

signal UpdateGraph(scrolltype, parameter, parameter2, parameter3, value)

func load_data(data):
	$Row/InnerGraphDraw/CheckBox.button_pressed = data[1]["inner graph boundary"]["draw"]
	$Row/InnerGraphWeight/SpinBox.value = data[1]["inner graph boundary"]["weight"]
	$Row/VMajorGridlines/MajorContainer/Weight/SpinBox.value = data[1]["vertical gridlines and ticks"]["major gridlines"]["weight"]
	$Row/VMajorGridlines/MajorContainer/ColorPickerButton.color = data[1]["vertical gridlines and ticks"]["major gridlines"]["colour"]
	$Row/VMinorGridlines/MinorContainer/Weight/SpinBox.value = data[1]["vertical gridlines and ticks"]["minor gridlines"]["weight"]
	$Row/VMinorGridlines/MinorContainer/Count/SpinBox.value = data[1]["vertical gridlines and ticks"]["minor gridlines"]["count"]
	$Row/VMinorGridlines/MinorContainer/ColorPickerButton.color = data[1]["vertical gridlines and ticks"]["minor gridlines"]["colour"]
	$Row/VMinorGridlines/CheckBox.button_pressed = data[1]["vertical gridlines and ticks"]["minor gridlines"]["draw"]
	$Row/HMajorGridlines/MajorContainer/Weight/SpinBox.value = data[1]["horizontal gridlines and ticks"]["major gridlines"]["weight"]
	$Row/HMajorGridlines/MajorContainer/ColorPickerButton.color = data[1]["horizontal gridlines and ticks"]["major gridlines"]["colour"]
	$Row/HMinorGridlines/MinorContainer/Weight/SpinBox.value = data[1]["horizontal gridlines and ticks"]["minor gridlines"]["weight"]
	$Row/HMinorGridlines/MinorContainer/Count/SpinBox.value = data[1]["horizontal gridlines and ticks"]["minor gridlines"]["count"]
	$Row/HMinorGridlines/MinorContainer/ColorPickerButton.color = data[1]["horizontal gridlines and ticks"]["minor gridlines"]["colour"]
	$Row/HMinorGridlines/CheckBox.button_pressed = data[1]["horizontal gridlines and ticks"]["minor gridlines"]["draw"]

func _InnerGraphDraw_toggled(toggled_on):
	UpdateGraph.emit("line", "inner graph boundary", "draw", null, toggled_on)

func _InnerGraphWeight_changed(value):
	UpdateGraph.emit("line", "inner graph boundary", "weight", null, value)

func _vgridline_weight_value_changed(value):
	UpdateGraph.emit("line", "vertical gridlines and ticks", "major gridlines", "weight", value)

func _on_v_minorgridlines_toggled(toggled_on):
	UpdateGraph.emit("line", "vertical gridlines and ticks", "minor gridlines", "draw", toggled_on)

func _on_vgridline_color_changed(color):
	UpdateGraph.emit("line", "vertical gridlines and ticks", "major gridlines", "colour", color)

func _on_v_minorgridline_changed(color):
	UpdateGraph.emit("line", "vertical gridlines and ticks", "minor gridlines", "colour", color)

func _on_v_minorgridlines_value_changed(value):
	UpdateGraph.emit("line", "vertical gridlines and ticks", "minor gridlines", "weight", value)

func _on_v_minorgridlines_count_value_changed(value):
	UpdateGraph.emit("line", "vertical gridlines and ticks", "minor gridlines", "count", value)

func _on_hgridlineweight_value_changed(value):
	UpdateGraph.emit("line", "horizontal gridlines and ticks", "major gridlines", "weight", value)

func _on_hgridline_color_changed(color):
	UpdateGraph.emit("line", "horizontal gridlines and ticks", "major gridlines", "colour", color)

func _on_h_minorgridlines_value_changed(value):
	UpdateGraph.emit("line", "horizontal gridlines and ticks", "minor gridlines", "weight", value)

func _on_h_minorgridlines_count_value_changed(value):
	UpdateGraph.emit("line", "horizontal gridlines and ticks", "minor gridlines", "count", value)

func _on_h_minorgridlines_color_changed(color):
	UpdateGraph.emit("line", "horizontal gridlines and ticks", "minor gridlines", "colour", color)

func _on_h_minorgridlines_toggled(toggled_on):
	UpdateGraph.emit("line", "horizontal gridlines and ticks", "minor gridlines", "draw", toggled_on)
