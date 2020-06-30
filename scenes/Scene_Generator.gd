extends Node2D


onready var back_to_menu_button: = $UI/BackToMenuButton
onready var water_repeatness: = $UI/Repeatness
onready var water_brush_size: = $UI/Size
onready var food_target_count: = $UI/Hunger


func _unhandled_key_input(event: InputEventKey) -> void:
    if event.pressed:
        back_to_menu_button.grab_focus()
        if event.scancode == KEY_ESCAPE:
            _on_BackToMenuButton_pressed()


func _on_BackToMenuButton_pressed() -> void:
    #warning-ignore:return_value_discarded
    get_tree().change_scene("res://scenes/Scene_MainMenu.tscn")


func _on_PlayButton_pressed() -> void:
    G.player.reset_to_defaults()
    G.player.level = 900000
    var ld: = LevelDescription.new()
    ld.need_food = int(food_target_count.value)
    ld.players = [Actors.Husband]
    ld.enemies = [Actors.Dog]
    ld.enemy_spawn_delay = 1.5
    ld.gen_water_count = int(water_brush_size.value)
    ld.gen_attempts = int(water_repeatness.value)
    G.custom_level_description = ld
    #warning-ignore:return_value_discarded
    get_tree().change_scene("res://scenes/Scene_PlayLevel.tscn")
