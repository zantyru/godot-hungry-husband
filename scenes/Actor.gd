extends Node2D
class_name Actor


enum {NO_DRIVEN, HUMAN_DRIVEN, CPU_DRIVEN}
enum {IDLE, WALK}
const __ANIMNAMES: Dictionary = {
    IDLE: {
        Step.UNDEFINED: "",
        Step.UP: "idle_up",
        Step.RIGHT: "idle_right",
        Step.DOWN: "idle_down",
        Step.LEFT: "idle_left"
    },
    WALK: {
        Step.UNDEFINED: "",
        Step.UP: "move_up",
        Step.RIGHT: "move_right",
        Step.DOWN: "move_down",
        Step.LEFT: "move_left"
    }
}
const __ANIMLENGHTS: Dictionary = {
    IDLE: 1,
    WALK: 2
}
const __SHEET_COLS: int = 3
const __SHEET_ROWS: int = 4

export (AtlasTexture) var character_sheet_3x4
onready var _sprite: = $Sprite
onready var _tween: = $Tween
var _is_tweening: bool = false
var _old_cellular_position: Vector2 = Vector2()
var _map: Map = null
var _tile_size: Vector2 = Vector2()
var type: int = NO_DRIVEN setget set_type
var state: int = IDLE setget set_state
var direction: int = Step.DOWN setget set_direction
var cellular_position: Vector2 = Vector2() setget set_cellular_position


func _ready():
    _initialization()


func _initialization() -> void:
    
    if character_sheet_3x4 == null:
        call_deferred("queue_free")
        return
    
    var frames: SpriteFrames = SpriteFrames.new()
    for type in [IDLE, WALK]:
        for dir in Step.DIRECTIONS:
            frames.add_animation(__ANIMNAMES[type][dir])
    for dir in Step.DIRECTIONS:
        frames.set_animation_loop(__ANIMNAMES[WALK][dir], true)
    
    var frame: AtlasTexture
    var pos_x: float = character_sheet_3x4.region.position.x
    var pos_y: float = character_sheet_3x4.region.position.y
    var tile_pos: = Vector2()
    var tile_size: = G.vec2_cdiv(
        character_sheet_3x4.region.size,
        Vector2(__SHEET_COLS, __SHEET_ROWS)
    )
    
    tile_pos.x = pos_x
    for state in [IDLE, WALK]:
        tile_pos.y = pos_y
        for dir in Step.DIRECTIONS:
            for shift in __ANIMLENGHTS[state]:
                frame = AtlasTexture.new()
                frame.atlas = character_sheet_3x4
                frame.region = Rect2(tile_pos + Vector2(shift * tile_size.x, 0), tile_size)
                frames.add_frame(__ANIMNAMES[state][dir], frame)
            tile_pos.y += tile_size.y
        tile_pos.x += tile_size.x * __ANIMLENGHTS[state]
    
    _sprite.frames = frames


func _wrap_coordinates(x: int, y: int) -> Vector2:
    x = x % _map.get_width()
    y = y % _map.get_height()
    if x < 0:
        x += _map.get_width()
    if y < 0:
        y += _map.get_height()
    return Vector2(x, y)


func _wrap_coordinatesv(v: Vector2) -> Vector2:
    return _wrap_coordinates(int(floor(v.x)), int(floor(v.y)))


func setup(actor_type: int, map: Map, tile_size: Vector2) -> void:
    type = actor_type
    _map = map
    _tile_size = tile_size
    #_tween.remove_all()


func is_busy() -> bool:
    return _is_tweening


func set_type(value: int) -> void:
    if is_busy():
        return
    type = value


func set_state(value: int) -> void:
    if is_busy():
        return
    state = value


func set_direction(value: int) -> void:
    if is_busy():
        return
    direction = value


func set_cellular_position(value: Vector2) -> void:
    if is_busy():
        return
    _old_cellular_position = cellular_position
    cellular_position = _wrap_coordinatesv(value)


func do(animation_duration: float = 0.0) -> void:
    if is_busy():
        return
    if direction == Step.UNDEFINED:
        state = IDLE
    _sprite.play(__ANIMNAMES[state][direction])
    if state == WALK:
        set_cellular_position(cellular_position + Step.VECTOR[direction])
        update_position_with_animation(animation_duration)


func update_position() -> void:
    if is_busy():
        return
    position = G.vec2_cmul(
        cellular_position,
        _tile_size
    )


func update_position_with_animation(animation_duration: float) -> void:
    
    if is_busy():
        return
    if animation_duration <= 0.0:
        return
    
    var motion_vector: = cellular_position - _old_cellular_position
    var direction_vector: Vector2 = Step.VECTOR[direction]
    
    var wrapping: = motion_vector != direction_vector
    
    if wrapping:
        motion_vector = G.vec2_cmul(_tile_size, direction_vector)
    else:
        motion_vector = G.vec2_cmul(_tile_size, motion_vector)
        
    if motion_vector.x != 0.0 or motion_vector.y != 0.0:
        _tween.interpolate_property(
            self,
            "position",
            position,
            position + motion_vector,
            animation_duration,
            Tween.TRANS_LINEAR,
            Tween.EASE_OUT
        )
        _tween.start()
        _is_tweening = true
        yield(_tween, "tween_completed")
        _is_tweening = false
    
    if wrapping:
        update_position()
