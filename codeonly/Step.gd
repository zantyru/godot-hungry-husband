extends Reference
class_name Step


enum {UNDEFINED, UP, RIGHT, DOWN, LEFT}
const DIRECTIONS: Array = [UP, RIGHT, DOWN, LEFT]
const VECTOR: Dictionary = {
    UNDEFINED: Vector2(),
    UP: Vector2(0, -1),
    RIGHT: Vector2(1, 0),
    DOWN: Vector2(0, 1),
    LEFT: Vector2(-1, 0)
    }
const DIRECTION: Dictionary = {
    Vector2(): UNDEFINED,
    Vector2(0, -1): UP,
    Vector2(1, 0): RIGHT,
    Vector2(0, 1): DOWN,
    Vector2(-1, 0): LEFT
    }
const OPPOSITE: Dictionary = {
    UNDEFINED: UNDEFINED,
    UP: DOWN,
    RIGHT: LEFT,
    DOWN: UP,
    LEFT: RIGHT
    }
