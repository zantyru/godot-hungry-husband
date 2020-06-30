extends Node2D


onready var level_counter: = $UI/UILevelCounter
onready var resume_button: = $UI/ResumeButton


func _unhandled_key_input(event: InputEventKey) -> void:
    if event.pressed:
        resume_button.grab_focus()
        if event.scancode == KEY_ESCAPE:
            _on_ResumeButton_pressed()


func _on_ResumeButton_pressed() -> void:
    get_tree().paused = false
    visible = false


func _on_BackToMenuButton_pressed() -> void:
    get_tree().paused = false
    #warning-ignore:return_value_discarded
    get_tree().change_scene("res://scenes/Scene_GameOver.tscn")


func _on_Scene_Pause_visibility_changed() -> void:
    if visible:
        get_tree().paused = true
        level_counter.value = G.player.level
