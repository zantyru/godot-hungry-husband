extends Node2D


onready var label: = $Control/Value
var value: int = 0 setget set_value


func set_value(new_value: int) -> void:
    value = new_value
    label.text = "%06d" % new_value