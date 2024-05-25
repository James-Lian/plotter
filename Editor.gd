extends Control

# File path of the Welcome scene
const Welcome = "res://Welcome.tscn"
const WorkingArea = "res://WorkingArea.tscn"

@onready var Tabs = $V/H/TabContainer
@onready var current_tab : int = Tabs.current_tab
var tab_types: Array = [] # false for Welcome scene, true for Workspace scene

@onready var Inspector_Vbox = $V/H/RightPanel/MarginContainer/VBoxContainer
@onready var current_inspectors : Array = ["WelcomeScroll"]

@onready var Tree_UI = $V/H/LeftPanel/MarginContainer/VBoxContainer/Tree
var root

# Called when the node enters the scene tree for the first time.
func _ready():
	Tabs.set_tab_button_icon(0, load("res://Images/Icons/x.svg"))
	
	Tabs.connect("child_entered_tree", Callable(self, "_on_tab_container_child_entered_tree"))
	
	create_new_tree(get_instanced_scene_from_tab(0).hierarchy)
	
	tab_types.append(false)
	
	get_instanced_scene_from_tab(0).connections['New'].connect("pressed", Callable(self, "new_file"))
	show_inspectors()

func create_new_tree(tree: Dictionary):
	Tree_UI.clear()
	
	root = Tree_UI.create_item()
	Tree_UI.hide_root = true
	
	for key in tree:
		var curr_item = Tree_UI.create_item(root)
		
		if typeof(key) != TYPE_INT:
			curr_item.set_text(0, key)
		else:
			curr_item.set_text(0, "Graph#" + str(key))
			
		for value in tree[key]:
			var item_child = Tree_UI.create_item(curr_item)
			item_child.set_text(0, value)

func load_inspectors_for_scene(inspectors_to_load):
	for node in current_inspectors:
		Inspector_Vbox.get_node(node).queue_free()
	
	current_inspectors.clear()
	var loaded_inspectors = []
	
	for i in range(0, len(inspectors_to_load)):
		if !loaded_inspectors.has(inspectors_to_load[i]):
			var scene = load(inspectors_to_load[i])
			var instance = scene.instantiate()
			instance.connect("UpdateGraph", Callable(self, "save_inspector_data"))
			Inspector_Vbox.add_child(instance)
			Inspector_Vbox.move_child(instance, 2 + i)
			
			current_inspectors.append(instance.get_path())
			loaded_inspectors.append(inspectors_to_load[i])
	
	show_inspectors()

func show_inspectors():
	var right_panel_vbox = $V/H/RightPanel/MarginContainer/VBoxContainer
	for child in right_panel_vbox.get_children():
		if "Scroll" in child.name:
			child.hide()
	
	if Tree_UI.get_selected() != null:
		if tab_types[current_tab]:
			if "Graph#" in Tree_UI.get_selected().get_text(0):
				right_panel_vbox.get_node("GraphScroll").show()
				var graph_index = Tree_UI.get_selected().get_text(0).replace("Graph#", "")
				get_instanced_scene_from_tab(current_tab).get_node("Graphs").get_child(int(graph_index)).emit_input()
				
			else:
				right_panel_vbox.get_node(Tree_UI.get_selected().get_text(0) + "Scroll").show()
				load_inspector_data()

func load_inspector_data():
	var right_panel_vbox = $V/H/RightPanel/MarginContainer/VBoxContainer
	var graph = get_instanced_scene_from_tab(current_tab).get_node("Graphs").get_child(int(Tree_UI.get_selected().get_text(0).replace("Graph#", "")))
	if "LineSeries" in Tree_UI.get_selected().get_text(0):
		pass
	elif "LineGraph" in Tree_UI.get_selected().get_text(0):
		right_panel_vbox.get_node(Tree_UI.get_selected().get_text(0) + "Scroll").load_data([graph.dataset, graph.get_node("LineGraph").chart_parameters])
	elif "Graph" in Tree_UI.get_selected().get_text(0):
		var data = {
			"position" = graph.position,
			"size" = graph.scale,
			"data" = graph.dataset
		}
		right_panel_vbox.get_node(Tree_UI.get_selected().get_text(0) + "Scroll").load_data(data)

func save_inspector_data(scrolltype, parameter, parameter2, parameter3, value):
	var graph = get_instanced_scene_from_tab(current_tab).get_node("Graphs").get_child(int(Tree_UI.get_selected().get_text(0).replace("Graph#", "")))
	if scrolltype == "line":
		if parameter3 != null:
			graph.get_node("LineGraph").chart_parameters[parameter][parameter2][parameter3] = value
		elif parameter2 != null:
			graph.get_node("LineGraph").chart_parameters[parameter][parameter2] = value
		else:
			graph.get_node("LineGraph").chart_parameters[parameter] = value
		graph.get_node("LineGraph").update_graph()
	elif scrolltype == "graph":
		pass
	elif scrolltype == "series":
		pass

### FUNCTIONAL FUNCTIONS ###
func new_file():
	add_instance_as_tab(WorkingArea)
	Tabs.current_tab = Tabs.get_child_count() - 1
	connect_workspace_signals(get_instanced_scene_from_tab(Tabs.current_tab))

func save_image():
	pass

## Used to make the workflow faster
func add_instance_as_tab(scene_path: String):
	var subviewportcontainer = SubViewportContainer.new()
	subviewportcontainer.stretch = true
	
	var subviewport = SubViewport.new()
	subviewport.physics_object_picking = true
	subviewportcontainer.add_child(subviewport)
	
	var scene = load(scene_path)
	var instance = scene.instantiate()
	subviewport.add_child(instance)
	
	Tabs.add_child(subviewportcontainer)
	
	if scene_path == Welcome:
		tab_types.append(false)
		Tabs.set_tab_title(Tabs.get_child_count()-1, "[Welcome]")
		subviewport.get_child(0).connections['New'].connect("pressed", Callable(self, "new_file"))
	else:
		tab_types.append(true)
		Tabs.set_tab_title(Tabs.get_child_count() - 1, "[unsaved file]")

func get_instanced_scene_from_tab(tab):
	return Tabs.get_child(current_tab).get_child(0).get_child(0)


### CONNECTIONS ###

# Used to connect any Workspace scenes with the proper signals
func connect_workspace_signals(node):
	node.connect("SelectedBoard", Callable(self, "select_tree_item_graph"))

func select_tree_item_graph(index):
	var curr_tree_item = Tree_UI.get_root().get_first_child()
	
	var tree_item_to_select = null
	while tree_item_to_select == null:
		if curr_tree_item.get_text(0).replace("Graph#", "") != str(index):
			curr_tree_item = curr_tree_item.get_next()
		else:
			tree_item_to_select = curr_tree_item
	
	Tree_UI.set_selected(tree_item_to_select, 0)
	Tree_UI.grab_focus()
	
	get_instanced_scene_from_tab(current_tab).get_node("Graphs").get_child(index).emit_input()

func _on_tab_container_tab_changed(tab):
	current_tab = tab
	
	load_inspectors_for_scene(get_instanced_scene_from_tab(tab).inspectors)
	create_new_tree(get_instanced_scene_from_tab(tab).hierarchy)

func _on_tab_container_tab_button_pressed(tab):
	tab_types.pop_at(tab)
	if Tabs.get_child_count() == 1:
		Tabs.get_child(tab).free()
		
		add_instance_as_tab(Welcome)
	else:
		Tabs.get_child(tab).queue_free()

func _on_tab_container_child_entered_tree(node):
	await get_tree().process_frame
	Tabs.set_tab_button_icon(node.get_index(), load("res://Images/Icons/x.svg"))

# When something on the popup menu is pressed
func _on_file_index_pressed(index):
	if index == 0:
		new_file()
	elif index == 1:
		pass
	elif index == 3:
		add_instance_as_tab(Welcome)

func _on_tab_container_active_tab_rearranged(idx_to):
	var type = tab_types[current_tab]
	tab_types.pop_at(current_tab)
	tab_types.insert(idx_to, type)
	
	current_tab = idx_to
