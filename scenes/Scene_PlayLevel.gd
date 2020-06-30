extends Node2D


onready var level: = $Level
onready var score_counter: = $UI/UIScoreCounter
onready var level_counter: = $UI/UILevelCounter
onready var food_counter: = $UI/UITotalFoodCounter
onready var life_counter: = $UI/UILifeCounter
onready var health_bar: = $UI/UIHealthBar
onready var stomach_bar: = $UI/UIStomachBar
onready var scene_pause: = $Scene_Pause


func _ready():
    scene_pause.visible = false
    G.player.health_drain_speed = -8.0
    level.player = G.player
    food_counter.value = 0
    new_level()
    update_ui()


func _unhandled_key_input(event: InputEventKey) -> void:
    if event.pressed and event.scancode == KEY_ESCAPE:
        #warning-ignore:return_value_discarded
        if not scene_pause.visible:
            G.player.score = score_counter.value
            G.player.food = food_counter.value
            scene_pause.visible = true


func new_level() -> void:
    var ld: LevelDescription
    if level.player != null:
        ld = G.custom_level_description
        if ld == null:
            ld = Levels.get_level_description(level.player.level)
        level.generate(ld)


func update_ui() -> void:
    life_counter.value = G.player.life_count
    health_bar.value = G.player.health
    stomach_bar.value = 0.0
    level_counter.value = G.player.level


func _on_Level_food_picked_up(cost: int) -> void:
    score_counter.value += cost
    food_counter.value += 1


#warning-ignore:unused_argument
func _on_Level_health_changed(difference: float) -> void:
    health_bar.value = G.player.health


#warning-ignore:unused_argument
func _on_Level_goal_changed(difference: int) -> void:
    var curr: int = G.player.have_food
    var need: int = G.player.need_food
    stomach_bar.value = stomach_bar.max_value * float(curr) / float(need)


func _on_Level_health_out() -> void:
    G.player.health = G.player.DEFAULT.HEALTH_MAX


func _on_Level_goal_reached() -> void:
    G.player.level += 1
    G.is_tutorial_passed = G.player.level > 2
    new_level()
    update_ui()


#warning-ignore:unused_argument
func _on_Level_lifes_changed(difference: int) -> void:
    life_counter.value += difference


func _on_Level_lifes_out() -> void:
    G.player.score = score_counter.value
    G.player.food = food_counter.value
    #warning-ignore:return_value_discarded
    get_tree().change_scene("res://scenes/Scene_GameOver.tscn")


#warning-ignore:unused_argument
func _on_Level_player_catched(player_actor: Actor, enemy_actor: Actor) -> void:
    G.player.health = G.player.DEFAULT.HEALTH_MAX
    level.remove_actor(player_actor)
    level.add_actor(Actors.Husband.instance(), Actor.HUMAN_DRIVEN)
