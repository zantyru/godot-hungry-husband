extends Node2D


onready var score_counter: = $UI/UIScoreCounter
onready var level_counter: = $UI/UILevelCounter
onready var food_counter: = $UI/UITotalFoodCounter
onready var back_to_menu_button: = $UI/BackToMenuButton


func _ready() -> void:
    score_counter.value = G.player.score
    level_counter.value = G.player.level
    food_counter.value = G.player.food


func _unhandled_key_input(event: InputEventKey) -> void:
    if event.pressed:
        back_to_menu_button.grab_focus()
        if event.scancode == KEY_ESCAPE:
            _on_BackToMenuButton_pressed()


func _on_BackToMenuButton_pressed() -> void:
    #warning-ignore:return_value_discarded
    get_tree().change_scene("res://scenes/Scene_MainMenu.tscn")
