extends Reference
class_name Map


const _NO_TILE: = -1

var _field: Dictionary = {}
var _contour: Dictionary = {}
var _picture: Dictionary = {}
var _tracked_tile: int = _NO_TILE
var _w: int = 0
var _h: int = 0


func _init(width: int, height: int) -> void:
    if width < 1 or height < 1:
        push_warning(
            "<Map._init()> Wrong size: width = {a}, height = {b}".format(
                {"a": width, "b": height}
            )
        )
        return
    _w = width
    _h = height
    for y in _h:
        for x in _w:
            _field[Vector2(x, y)] = Tiles.GRASS


func set_tile(x: int, y: int, tile: int) -> void:
    var coords: = _wrap_coordinatesv(Vector2(x, y))
    _field[coords] = tile


func get_tile(x: int, y: int) -> int:
    return _field[_wrap_coordinates(x, y)]


func get_width() -> int:
    return _w


func get_height() -> int:
    return _h


func _wrap_coordinates(x: int, y: int) -> Vector2:
    x = x % _w
    y = y % _h
    if x < 0:
        x += _w
    if y < 0:
        y += _h
    return Vector2(x, y)


func _wrap_coordinatesv(v: Vector2) -> Vector2:
    return _wrap_coordinates(int(floor(v.x)), int(floor(v.y)))


func clear(brush_tile: int = Tiles.GRASS) -> void:
    for cell in _field:
        _field[cell] = brush_tile


func draw_tile(x: int, y: int, brush_tile: int) -> void:
    _draw_tile(Vector2(x, y), brush_tile)


func _draw_tile(coords: Vector2, brush_tile: int) -> void:
    coords = _wrap_coordinatesv(coords)
    _field[coords] = brush_tile
    if _tracked_tile == brush_tile:
        _picture[coords] = null
        #warning-ignore:return_value_discarded
        _contour.erase(coords)
        var offsets: = [
            Vector2(0, -1),
            Vector2(1, -1),
            Vector2(1, 0),
            Vector2(1, 1),
            Vector2(0, 1),
            Vector2(-1, 1),
            Vector2(-1, 0),
            Vector2(-1, -1)
        ]
        var neighbor: Vector2
        #var neighbor_offset: Vector2
        for offset in offsets:
            neighbor = _wrap_coordinatesv(coords + offset)
            if neighbor in _picture:
                continue
            _contour[neighbor] = offset


func draw_tile_sized(x: int, y: int, brush_tile: int, brush_size: int) -> void:
    _draw_tile_sized(Vector2(x, y), brush_size, brush_tile)


func _draw_tile_sized(coords: Vector2, brush_tile: int, brush_size: int) -> void:
    if brush_size < 1:
        return
    var half: = Vector2(brush_size >> 1, brush_size >> 1)    
    for v in brush_size:
        for u in brush_size:
            _draw_tile(coords - half + Vector2(u, v), brush_tile)


func generate_canals(rnd: RandomNumberGenerator, start_x: int, start_y: int,
                     brush_tile: int, brush_size: int, attempts: int) -> void:
    
    if attempts < 1:
        attempts = 1
    
    _tracked_tile = brush_tile
    
    var coords: = Vector2(start_x, start_y)
    _draw_tile_sized(coords, brush_tile, brush_size)
    
    var variants: Array
    var offset: Vector2
    
    # Рисуем "кистью" исходного размера
    
    #warning-ignore:integer_division
    for i in 2 * attempts / 3:
        variants = _contour.keys()
        if variants.size() == 0:
            break
        coords = variants[rnd.randi() % variants.size()]
        offset = _contour[coords]
        _draw_tile_sized(coords - offset, brush_tile, brush_size)
    
    # Рисуем "кистью" на размер меньше
    
    brush_size >>= 1
    if brush_size < 1:
        brush_size = 1
    
    #warning-ignore:integer_division
    for i in attempts / 3:
        variants = _contour.keys()
        if variants.size() == 0:
            break
        coords = variants[rnd.randi() % variants.size()]
        offset = _contour[coords]
        _draw_tile_sized(coords - offset, brush_tile, brush_size)
    
    _tracked_tile = _NO_TILE
    _contour.clear()
    _picture.clear()
