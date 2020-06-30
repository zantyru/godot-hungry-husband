extends Reference
class_name Player


const DEFAULT: Dictionary = {
    LIFE_COUNT = 3, #int
    HEALTH_MAX = 100.0, #float
    HEALTH_MIN = 0.0, #float
    HEALTH_DRAIN_SPEED = -1.0, #float
}

# Vitality
var life_count: int = DEFAULT.LIFE_COUNT setget set_life_count
var health_max: float = DEFAULT.HEALTH_MAX setget set_health_max
var health_min: float = DEFAULT.HEALTH_MIN setget set_health_min
var health: float = DEFAULT.HEALTH_MAX setget set_health
var health_drain_speed: float = DEFAULT.HEALTH_DRAIN_SPEED
# Inventory
var need_food: int = 0 setget set_target_food_count, get_target_food_count
var have_food: int = 0 setget set_current_food_count, get_current_food_count
# Score
var score: int = 0
var food: int = 0
var level: int = 1


func reset_to_defaults() -> void:
    # Vitality
    life_count = DEFAULT.LIFE_COUNT
    health_max = DEFAULT.HEALTH_MAX
    health_min = DEFAULT.HEALTH_MIN
    health = DEFAULT.HEALTH_MAX
    health_drain_speed = DEFAULT.HEALTH_DRAIN_SPEED
    # Inventory
    need_food = 0
    have_food = 0
    # Score
    score = 0
    food = 0
    level = 1


func set_life_count(count: int) -> void:
    if count < 0:
        count = 0
    life_count = count


func change_life_count(difference: int) -> int:
    var result: = life_count + difference
    var clamped: = 0 if result < 0 else result
    difference += clamped - result
    life_count = clamped
    return difference


func set_health_max(value: float) -> void:
    if value < health_min:
        value = health_min
    health_max = value
    if health > health_max:
        health = health_max


func set_health_min(value: float) -> void:
    if value > health_max:
        value = health_max
    health_min = value
    if health < health_min:
        health = health_min


func set_health(value: float) -> void:
    health = clamp(value, health_min, health_max)


func change_health(difference: float) -> float:
    var result: = health + difference
    var clamped: = clamp(result, health_min, health_max)
    difference += clamped - result
    health = clamped
    return difference


func set_target_food_count(count: int) -> void:
    if count < 0:
        count = 0
    need_food = count


func get_target_food_count() -> int:
    return need_food


func set_current_food_count(count: int) -> void:
    if count < 0:
        count = 0
    have_food = count


func get_current_food_count() -> int:
    return have_food


func change_current_food_count(difference: int) -> int:
    var result: = have_food + difference
    var clamped: = 0 if result < 0 else result
    difference += clamped - result
    have_food = clamped
    return difference
