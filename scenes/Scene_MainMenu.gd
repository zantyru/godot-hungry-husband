extends Node2D


onready var new_game_button: = $UI/NewGameButton
onready var continue_button: = $UI/ContinueButton


func _ready() -> void:
    continue_button.disabled = false if G.is_tutorial_passed else true


func _unhandled_key_input(event: InputEventKey) -> void:
    if event.pressed:
        new_game_button.grab_focus()


func _on_NewGameButton_pressed() -> void:
    G.player.reset_to_defaults()
    G.custom_level_description = null
    #warning-ignore:return_value_discarded
    get_tree().change_scene("res://scenes/Scene_PlayLevel.tscn")


func _on_ContinueButton_pressed() -> void:
    G.player.reset_to_defaults()
    G.player.level = 3
    G.custom_level_description = null
    #warning-ignore:return_value_discarded
    get_tree().change_scene("res://scenes/Scene_PlayLevel.tscn")


func _on_ExitButton_pressed() -> void:
    get_tree().quit()


func _on_HelpButton_pressed() -> void:
    #warning-ignore:return_value_discarded
    get_tree().change_scene("res://scenes/Scene_Help.tscn")


func _on_GeneratorButton_pressed() -> void:
    #warning-ignore:return_value_discarded
    get_tree().change_scene("res://scenes/Scene_Generator.tscn")
