extends Control

class_name ResultUI

@onready var result_title: Label = $PanelContainer/VBoxContainer/MarginContainer/TabContainer/Report/VBoxContainer/Title
@onready var team_stats: Array[TeamStats] = [
	$PanelContainer/VBoxContainer/MarginContainer/TabContainer/Report/VBoxContainer/HBoxContainer/TeamStats, 
	$PanelContainer/VBoxContainer/MarginContainer/TabContainer/Report/VBoxContainer/HBoxContainer/TeamStats2, 
	$PanelContainer/VBoxContainer/MarginContainer/TabContainer/Report/VBoxContainer/HBoxContainer/TeamStats3, 
	$PanelContainer/VBoxContainer/MarginContainer/TabContainer/Report/VBoxContainer/HBoxContainer/TeamStats4
]
@onready var timeline: Timeline = $PanelContainer/VBoxContainer/MarginContainer/TabContainer/Timeline
