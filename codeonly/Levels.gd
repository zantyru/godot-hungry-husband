extends Reference
class_name Levels


static func get_level_description(level: int) -> LevelDescription:
    var ld: = LevelDescription.new()
    if level <= 1:
        ld.custom_level = "res://scenes/CustomLevel_1_Tutorial.tscn"
    elif level <= 2:
        ld.custom_level = "res://scenes/CustomLevel_2_Tutorial.tscn"
    elif level <= 4:
        ld.need_food = 5
        ld.players = [Actors.Husband]
        ld.enemies = [Actors.Dog]
        ld.enemy_spawn_delay = 2.0
        ld.gen_water_count = 2
        ld.gen_attempts = 18
    elif level <= 6:
        ld.need_food = 7
        ld.players = [Actors.Husband]
        ld.enemies = [Actors.Dog]
        ld.enemy_spawn_delay = 1.5
        ld.gen_water_count = 5
        ld.gen_attempts = 19
    elif level <= 9:
        ld.need_food = 8
        ld.players = [Actors.Husband]
        ld.enemies = [Actors.Dog]
        ld.enemy_spawn_delay = 1.0
        ld.gen_water_count = 3
        ld.gen_attempts = 30
    else:
        ld.need_food = 10
        ld.players = [Actors.Husband]
        ld.enemies = [Actors.Dog]
        ld.enemy_spawn_delay = 1.0
        ld.gen_water_count = 8
        ld.gen_attempts = 9
    return ld
