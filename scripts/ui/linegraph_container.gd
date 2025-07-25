@tool
extends Control

@onready var line_graph = $LineGraph

func _on_resized() -> void:
	line_graph.graph_width = size.x - line_graph.left_margin - line_graph.right_margin
	line_graph.graph_height = size.y - line_graph.top_margin - line_graph.bot_margin
