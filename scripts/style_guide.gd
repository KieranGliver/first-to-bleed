# This is a comment.
#print("This is disabled code")

# 01. @tool, @icon, @static_unload
# 02. class_name
# 03. extends
# 04. ## doc comment

# 05. signals
# 06. enums
# 07. constants
# 08. static variables
# 09. @export variables
# 10. remaining regular variables
# 11. @onready variables

# 12. _static_init()
# 13. remaining static methods
# 14. overridden built-in virtual methods:
#	1. _init()
#	2. _enter_tree()
#	3. _ready()
#	4. _process()
#	5. _physics_process()
#	6. remaining virtual methods
# 15. overridden custom methods
# 16. remaining methods
# 17. subclasses

#@tool, @icon, @static_unload
# This file should be saved as 'style_guide.gd' (snake_case).
class_name StyleGuide
# Use PascalCase for class and nodes:
extends Node
## A brief description of the class's role and functionality.
##
## The description of the script, what it can do,
## and any further detail.

## Style guide outline for Godot 4.3
##
## Contains style guide set by Godot engine 
## (https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html) 
## by Eggsenbacon

# Signals use 
signal sig(variable)

# Enums use PascalCase
enum En{
	# Enum members use CONSTANT_CASE
	EN1,
	EN2,
	EN3,
	EN4,
}

# Constants use CONSTANT_CASE
const MAX_INT: int = 0x7fff_ffff_ffff_ffff # 2^63 - 1 or 9223372036854775807
# Also use PascalCase when loading a class into a constant or a variable:
const StyleG = preload("res://scripts/style_guide.gd")

# Variables use snake_case
static var state: En = En.EN3
# The type can be int or float, and thus should be stated explicitly.
@export var health: int = 10
# The type is clearly inferred as String.
var s := "hello world"
var arr: Array[float] = [1.0, 2.0, 3]
# GDScript evaluates @onready variables right before the _ready callback.
@onready var scene: PackedScene = load("res://scenes/style_guide.tscn")


# functions use snake_case
# Prepend a single underscore (_) to virtual methods functions the user must override, 
# private functions, and private variables:
func _init() -> void:
	print("init")


# Surround functions and class definitions with two blank lines:
func _enter_tree() -> void:
	print("enter tree")


func _ready() -> void:
	
	# Normal string.
	print(s)
	
	# Use double quotes as usual to avoid escapes.
	print("'MAX_INT' in Godot: ", MAX_INT)
	
	# Use single quotes as an exception to the rule to avoid escapes.
	print('"ready"')
	
	# Both quote styles would require 2 escapes; prefer double quotes if it's a tie.
	print("'hello' \"world\"")


func _process(delta: float) -> void:
	#print("process: ", delta)
	pass


func _physics_process(delta: float) -> void:
	#print("physics_process: ", delta)
	pass


func _unhandled_input(event: InputEvent) -> void:
	#print(event)
	pass
