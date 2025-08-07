extends Control

class_name BattleUI

@onready var timer = $Timer
@onready var ducat = $Ducat
@onready var score = $ScoreBar
@onready var deck = $Deck
@onready var wood = $Wood
@onready var stone = $Stone
@onready var coords = $Coords
@onready var time_buttons = [$PanelContainer/MarginContainer/VBoxContainer/PauseButton, $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/SpeedOne, $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/SpeedTwo, $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/SpeedThree, $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/SpeedFour]
