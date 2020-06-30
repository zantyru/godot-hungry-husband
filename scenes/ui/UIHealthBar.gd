extends Node2D


onready var bar: = $Control/Bar
var value: float = 0.0 setget set_value
var max_value: float = 0.0
var min_value: float = 0.0


func _ready() -> void:
    max_value = bar.max_value
    min_value = bar.min_value


func set_value(new_value: float) -> void:
    value = new_value
    bar.value = value