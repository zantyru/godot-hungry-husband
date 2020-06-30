extends Reference
class_name Pathfinder


const _DEFAULT: int = 0

var _field: Dictionary = {}
var _w: int = 0
var _h: int = 0


func _init(width: int, height: int) -> void:
    if width < 1 or height < 1:
        push_warning(
            "<Pathfinder._init()> Wrong size: width = {a}, height = {b}".format(
                {"a": width, "b": height}
            )
        )
        return
    _w = width
    _h = height
    _clear(true)


func _clear(initialization: bool = false) -> void:
    if initialization:
        for y in _h:
            for x in _w:
                _field[Vector2(x, y)] = _DEFAULT
    else:
        for cell in _field:
            _field[cell] = _DEFAULT


func _is_correct(x: int, y: int) -> bool:
    return not (x < 0 or x >= _w or y < 0 or y >= _h)


func block_cell(x: int, y: int) -> void:
    if not _is_correct(x, y):
        push_warning(
            "<Pathfinder.block_cell()> Wrong coordinates: x = {a}, y = {b}".format(
                {"a": x, "b": y}
            )
        )
        return
    var i: = Vector2(x, y)
    if i in _field:
        #warning-ignore:return_value_discarded
        _field.erase(i)


func unblock_cell(x: int, y: int) -> void:
    if not _is_correct(x, y):
        push_warning(
            "<Pathfinder.unblock_cell()> Wrong coordinates: x = {a}, y = {b}".format(
                {"a": x, "b": y}
            )
        )
        return
    var i: = Vector2(x, y)
    if not (i in _field):
        _field[i] = _DEFAULT


func is_blocked(x: int, y: int) -> bool:
    if not _is_correct(x, y):
        push_warning(
            "<Pathfinder.is_blocked()> Wrong coordinates: x = {a}, y = {b}".format(
                {"a": x, "b": y}
            )
        )
        return true
    var i: = Vector2(x, y)
    return not (i in _field)


func update_path_to(x: int, y: int) -> void:
    
    if not _is_correct(x, y):
        push_warning(
            "<Pathfinder.update_path_to()> Wrong coordinates: x = {a}, y = {b}".format(
                {"a": x, "b": y}
            )
        )
        return
    
    if not (Vector2(x, y) in _field):
        return
    
    var visited: = {}
    var next: = {} # used as ordered set (it is faster than Array!)
    var neighbor_cell: Vector2
    
    _clear()
    _field[Vector2(x, y)] = _DEFAULT
    next[Vector2(x, y)] = null
    for cell in next:
        visited[cell] = null # used as set
        for direction in Step.DIRECTIONS:
            neighbor_cell = cell + Step.VECTOR[direction]
            if not (neighbor_cell in _field) or neighbor_cell in visited:
                continue
            _field[neighbor_cell] = _field[cell] + 1
            next[neighbor_cell] = null


func get_step_from(x: int, y: int) -> int:
    
    if not _is_correct(x, y):
        push_warning(
            "<Pathfinder.get_step_from()> Wrong coordinates: x = {a}, y = {b}".format(
                {"a": x, "b": y}
            )
        )
        return Step.UNDEFINED
    
    var cell: = Vector2(x, y)
    if not (cell in _field):
        return Step.UNDEFINED
    
    var BIG_VALUE = _w * _h
    var neighbor_cell: Vector2
    var best_direction: = Step.UNDEFINED
    var cell_depth: int
    var neighbor_cell_depth: int
    
    for direction in Step.DIRECTIONS:
        neighbor_cell = cell + Step.VECTOR[direction]
        cell_depth = _field[cell]
        neighbor_cell_depth = _field.get(neighbor_cell, BIG_VALUE)
        if neighbor_cell_depth < cell_depth:
            best_direction = direction
    
    return best_direction


func get_random_free_cell(rnd: RandomNumberGenerator) -> Vector2:
    var available_cells: = _field.keys()
    var cell: Vector2
    if available_cells:
        cell = available_cells[rnd.randi() % available_cells.size()]
    else:
        cell = Vector2()
    return cell
