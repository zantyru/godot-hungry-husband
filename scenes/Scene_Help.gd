extends Node2D


onready var back_to_menu_button: = $UI/BackToMenuButton


func _unhandled_key_input(event: InputEventKey) -> void:
    if event.pressed:
        back_to_menu_button.grab_focus()
        if event.scancode == KEY_ESCAPE:
            _on_BackToMenuButton_pressed()


func _on_BackToMenuButton_pressed() -> void:
    #warning-ignore:return_value_discarded
    get_tree().change_scene("res://scenes/Scene_MainMenu.tscn")
