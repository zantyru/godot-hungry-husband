extends Node2D
class_name Food


const __SHEET_COLS: = 1
const __SHEET_ROWS: = 1

export (AtlasTexture) var character_sheet_1x1
#warning-ignore:unused_class_variable
export (int, 0, 5000) var cost: int = 100
#warning-ignore:unused_class_variable
export (int, 0, 100) var will_restore_health: int = 20
onready var _sprite: = $Sprite
var _tile_size: Vector2 = Vector2()
var cellular_position: Vector2 = Vector2()


func _ready():
    _initialization()


func _initialization() -> void:    
    if character_sheet_1x1 == null:
        call_deferred("queue_free")
        return
    _sprite.texture = character_sheet_1x1


func setup(tile_size: Vector2) -> void:
    _tile_size = tile_size


func update_position() -> void:
    position = G.vec2_cmul(
        cellular_position,
        _tile_size
    )
