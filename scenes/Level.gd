extends TileMap
class_name Level


signal generating_started()
signal generating_finished()
signal lifes_changed(difference)
signal lifes_out()
signal health_changed(difference)
signal health_out()
signal goal_changed(difference)
signal goal_reached()
signal player_catched(player_actor, enemy_actor)
signal food_picked_up(cost)

const TILE_WIDTH: int = 16
const TILE_HEIGHT: int = 16
var TILE_SIZE: Vector2 = Vector2(TILE_WIDTH, TILE_HEIGHT) # 'const' throw error
const LEVEL_WIDTH: int = 24
const LEVEL_HEIGHT: int = 24
var LEVEL_SIZE: Vector2 = Vector2(LEVEL_WIDTH, LEVEL_HEIGHT) # 'const' throw error
const PLAYER_HEALTH_MAX: float = 100.0
const PLAYER_HEALTH_MIN: float = 0.0

export (float) var actor_move_duration: float = 0.3
var _rnd: RandomNumberGenerator = null
var _is_generating: = false
var _is_custom_level: = false
var _pathfinder: Pathfinder = null
var _map: Map = null
var _boundary: Rect2 = Rect2()
var _players_count: int = 0
var _player_direction_stack: Array = [Step.UNDEFINED]
var _player_state: int = Actor.IDLE
var _waiting_actors: Dictionary = {}
var _working_actors: Dictionary = {}
var _foods: Dictionary = {}
var player: Player = null


func _ready():
    cell_size = TILE_SIZE
    _pathfinder = Pathfinder.new(LEVEL_WIDTH, LEVEL_HEIGHT)
    _map = Map.new(LEVEL_WIDTH, LEVEL_HEIGHT)
    _boundary = Rect2(Vector2(), G.vec2_cmul(LEVEL_SIZE, TILE_SIZE))
    _rnd = RandomNumberGenerator.new()
    _rnd.randomize()


# Process

#warning-ignore:unused_argument
func _process(delta: float) -> void:
    if _is_generating:
        return
    if _players_count > 0:
        _prc_check_player_goal()
        _prc_check_player_health(delta)
    _prc_poll_input()   
    for actor in _working_actors:
        _prc_do_step(actor)
        _prc_check_catching(actor)


func _prc_check_player_health(delta: float) -> void:
    if player == null:
        return
    var drain: float = float(player.health_drain_speed) * delta
    if player.health <= player.health_min:
        if player.life_count == 0:
            emit_signal("lifes_out")
        else:
            emit_signal("lifes_changed",
                player.change_life_count(-1)
            )
        emit_signal("health_out")
        return
    emit_signal("health_changed",
        player.change_health(drain)
    )


func _prc_check_player_goal() -> void:
    if player == null:
        return
    if player.have_food >= player.need_food:
        emit_signal("goal_reached")


func _prc_poll_input() -> void:
    
    var pu: = Input.is_action_pressed("ui_up")
    var pr: = Input.is_action_pressed("ui_right")
    var pd: = Input.is_action_pressed("ui_down")
    var pl: = Input.is_action_pressed("ui_left")
    var jpu: = Input.is_action_just_pressed("ui_up")
    var jpr: = Input.is_action_just_pressed("ui_right")
    var jpd: = Input.is_action_just_pressed("ui_down")
    var jpl: = Input.is_action_just_pressed("ui_left")
    var jru: = Input.is_action_just_released("ui_up")
    var jrr: = Input.is_action_just_released("ui_right")
    var jrd: = Input.is_action_just_released("ui_down")
    var jrl: = Input.is_action_just_released("ui_left")
    var b: bool
    
    # Отжатие клавиши - выталкивание элемента из стека
    b = jru and _player_direction_stack[0] == Step.UP
    b = b or (jrr and _player_direction_stack[0] == Step.RIGHT)
    b = b or (jrd and _player_direction_stack[0] == Step.DOWN)
    b = b or (jrl and _player_direction_stack[0] == Step.LEFT)
    if b:
        _player_direction_stack.pop_front()
        if _player_direction_stack.empty():
            _player_direction_stack = [Step.UNDEFINED]
    
    # Реакция на нажатие
    if not (pu or pr or pd or pl):
        _player_state = Actor.IDLE
        _player_direction_stack = [Step.UNDEFINED]
    else:
        _player_state = Actor.WALK
        if jpu:
            _player_direction_stack.push_front(Step.UP)
        if jpr:
            _player_direction_stack.push_front(Step.RIGHT)
        if jpd:
            _player_direction_stack.push_front(Step.DOWN)
        if jpl:
            _player_direction_stack.push_front(Step.LEFT)


func _prc_do_step(actor: Actor) -> void:
    
    var vector: Vector2
    var x: int
    var y: int
    
    match actor.type:
        
        Actor.HUMAN_DRIVEN:
            x = int(actor.cellular_position.x)
            y = int(actor.cellular_position.y)
            if not actor.is_busy():   #@NEW
                _pathfinder.update_path_to(x, y)
            actor.direction = _player_direction_stack[0]
            actor.state = _player_state
        
        Actor.CPU_DRIVEN:
            x = int(actor.cellular_position.x)
            y = int(actor.cellular_position.y)
            if not actor.is_busy(): #@NEW
                actor.direction = _pathfinder.get_step_from(x, y)
            else: #@NEW
                actor.direction = Step.UNDEFINED #@NEW
            actor.state = Actor.IDLE if actor.direction == Step.UNDEFINED else Actor.WALK
    
    if actor.state == Actor.WALK:
        vector = actor.cellular_position + Step.VECTOR[actor.direction]
        x = int(vector.x)
        if x < 0:
            x += LEVEL_WIDTH
        elif x >= LEVEL_WIDTH:
            x -= LEVEL_WIDTH
        y = int(vector.y)
        if y < 0:
            y += LEVEL_HEIGHT
        elif y >= LEVEL_HEIGHT:
            y -= LEVEL_HEIGHT
        if _pathfinder.is_blocked(x, y):
            actor.state = Actor.IDLE
    
    actor.do(actor_move_duration)


func _prc_check_catching(actor: Actor) -> void:
    match actor.type:
        Actor.HUMAN_DRIVEN:
            for food in _foods:
                if actor.cellular_position == food.cellular_position:
                    emit_signal("food_picked_up", food.cost)
                    if player != null:
                        emit_signal("health_changed",
                            player.change_health(food.will_restore_health)
                        )
                        emit_signal("goal_changed",
                            player.change_current_food_count(1)
                        )
                    remove_food(food)
                    if player != null and player.have_food < player.need_food:
                        generate_food()
                    break
        Actor.CPU_DRIVEN:
            for player_actor in _working_actors:
                if player_actor.type != Actor.HUMAN_DRIVEN:
                    continue
                if actor.cellular_position == player_actor.cellular_position:
                    if player != null:
                        if player.life_count == 0:
                            emit_signal("lifes_out")
                        else:
                            emit_signal("lifes_changed",
                                player.change_life_count(-1)
                            )
                    emit_signal("player_catched", player_actor, actor)
                    break #@?


# Procedural generation

func generate(level_description: LevelDescription) -> void:
    
    if _is_generating:
        return
    _is_generating = true
    emit_signal("generating_started")
    
    var t: int
    _gen_clear()
    
    # Deploying custom level
    if level_description.custom_level != "":
        _is_custom_level = true
        var clvl: = load(level_description.custom_level) as PackedScene
        var clvl_instance: = clvl.instance() as CustomLevel
        if clvl_instance != null:
            # Tiles
            for y in LEVEL_HEIGHT:
                for x in LEVEL_WIDTH:
                    t = clvl_instance.get_cell(x, y)
                    _map.set_tile(x, y, t)
                    set_cell(x, y, t)
                    if t in Tiles.OBSTACLES:
                        _pathfinder.block_cell(x, y)
                    else:
                        _pathfinder.unblock_cell(x, y)
            # Spawning players
            for actor_position in clvl_instance.players_at:
                add_actor(Actors.Husband.instance(), Actor.HUMAN_DRIVEN, 0.0, actor_position)
            # Spawning enemies
            for actor_position in clvl_instance.enemies_at:
                add_actor(Actors.Dog.instance(), Actor.CPU_DRIVEN, 0.2, actor_position)
            # Spawning food
            for food_position in clvl_instance.foods_at:
                var f: Food
                if _rnd.randi() % 10 < 5:
                    f = Foods.FRUITS[_rnd.randi() % Foods.FRUITS.size()].instance()
                else:
                    f = Foods.VEGETABLES[_rnd.randi() % Foods.VEGETABLES.size()].instance()
                add_food(f, food_position)
            # Setup player data
            if player != null:
                player.need_food = clvl_instance.need_food
    
    # Generating new level
    else:
        _is_custom_level = false
        # Tiles
        _map.generate_canals(
            _rnd,
            _rnd.randi() % LEVEL_WIDTH,
            _rnd.randi() % LEVEL_HEIGHT,
            Tiles.WATER,
            level_description.gen_water_count,
            level_description.gen_attempts
        )
        for y in LEVEL_HEIGHT:
            for x in LEVEL_WIDTH:
                t = _map.get_tile(x, y)
                set_cell(x, y, t)
                if t in Tiles.OBSTACLES:
                    _pathfinder.block_cell(x, y)
                else:
                    _pathfinder.unblock_cell(x, y)
        # Spawning players
        for actor in level_description.players:
            add_actor(actor.instance(), Actor.HUMAN_DRIVEN)
        # Spawning enemies
        for actor in level_description.enemies:
            add_actor(actor.instance(), Actor.CPU_DRIVEN, level_description.enemy_spawn_delay)
        # Spawning food
        generate_food()
        # Setup player data
        if player != null:
            player.need_food = level_description.need_food
    
    _gen_wrap_edges()
    update_bitmask_region()
    _is_generating = false
    emit_signal("generating_finished")
    

func _gen_clear() -> void:
    
    if player != null:
        player.health = 100.0
        player.have_food = 0
    _player_direction_stack = [Step.UNDEFINED]
    _player_state = Actor.IDLE
    
    for actor in _working_actors.keys(): # because we use the 'erase' method
        remove_actor(actor)
    for food in _foods.keys():
        remove_food(food)
    _waiting_actors.clear()
    
    clear()
    _map.clear()
    for y in LEVEL_HEIGHT:
        for x in LEVEL_WIDTH:
            set_cell(x, y, Tiles.GRASS)
            _pathfinder.unblock_cell(x, y)


func _gen_wrap_edges() -> void:
    for x in LEVEL_WIDTH:
        set_cell(x, -1, get_cell(x, LEVEL_HEIGHT - 1))
        set_cell(x, LEVEL_HEIGHT, get_cell(x, 0))
    for y in LEVEL_HEIGHT:
        set_cell(-1, y, get_cell(LEVEL_WIDTH - 1, y))
        set_cell(LEVEL_WIDTH, y, get_cell(0, y))
    set_cell(-1, -1, get_cell(LEVEL_WIDTH - 1, LEVEL_HEIGHT - 1))
    set_cell(LEVEL_WIDTH, -1, get_cell(0, LEVEL_HEIGHT - 1))
    set_cell(LEVEL_WIDTH, LEVEL_HEIGHT, get_cell(0, 0))
    set_cell(-1, LEVEL_HEIGHT, get_cell(LEVEL_WIDTH - 1, 0))
        

# Scene objects

func add_actor(actor: Actor, type: int, delay: float = 0.0, cellular_position: Vector2 = Vector2(-1, -1)) -> void:
    
    if actor in _waiting_actors or actor in _working_actors:
        return
    
    actor.setup(type, _map, TILE_SIZE)
    if cellular_position == Vector2(-1, -1):
        actor.cellular_position = _pathfinder.get_random_free_cell(_rnd)
    else:
        actor.cellular_position = cellular_position
    
    if delay > 0.0:
        _waiting_actors[actor] = null
        yield(get_tree().create_timer(delay), "timeout")
        #warning-ignore:return_value_discarded
        _waiting_actors.erase(actor)
    
    if actor.type == Actor.HUMAN_DRIVEN:
        _players_count += 1
    
    _working_actors[actor] = null
    add_child(actor)
    actor.update_position()


func remove_actor(actor: Actor) -> void:
    if actor in _waiting_actors:
        return
    if _working_actors.erase(actor):
        remove_child(actor)
        actor.queue_free()
        if actor.type == Actor.HUMAN_DRIVEN:
            _players_count -= 1


func add_food(food: Food, cellular_position: Vector2 = Vector2(-1, -1)) -> void:
    food.setup(TILE_SIZE)
    if cellular_position == Vector2(-1, -1):
        food.cellular_position = _pathfinder.get_random_free_cell(_rnd)
    else:
        food.cellular_position = cellular_position
    _foods[food] = null
    add_child(food)
    food.update_position()


func remove_food(food: Food) -> void:
    #warning-ignore:return_value_discarded
    _foods.erase(food)
    remove_child(food)
    food.queue_free()


func generate_food() -> void:
    if _is_custom_level and _foods.size() > 0:
        return
    var f: Food
    if _rnd.randi() % 10 < 5:
        f = Foods.FRUITS[_rnd.randi() % Foods.FRUITS.size()].instance()
    else:
        f = Foods.VEGETABLES[_rnd.randi() % Foods.VEGETABLES.size()].instance()
    add_food(f)
