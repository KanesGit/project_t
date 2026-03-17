## Main.gd - 主场景控制器
## 游戏状态管理、砖块生成、胜负判定

extends Node2D

# 游戏状态枚举
enum GameState { READY, PLAYING, GAME_OVER, VICTORY }

# 场景引用
@export var ball_scene: PackedScene
@export var brick_scene: PackedScene

# 游戏对象
@onready var paddle: StaticBody2D = $Paddle
@onready var ball: CharacterBody2D = $Ball
@onready var bricks_container: Node2D = $Bricks
@onready var death_zone: Area2D = $DeathZone
@onready var ui: CanvasLayer = $UI
@onready var score_label: Label = $UI/ScoreLabel
@onready var message_label: Label = $UI/MessageLabel
@onready var victory_particles: GPUParticles2D = $VictoryParticles

# 游戏状态
var _state: GameState = GameState.READY
var _score: int = 0
var _brick_count: int = 0

# 砖块配置
const BRICK_ROWS := 4
const BRICK_COLS := 11
const BRICK_WIDTH := 64.0
const BRICK_HEIGHT := 24.0
const BRICK_GAP := 4.0

# 砖块颜色 (从上到下)
const BRICK_COLORS := [
	Color("#ff6b6b"),  # 红
	Color("#feca57"),  # 橙
	Color("#48dbfb"),  # 蓝
	Color("#1dd1a1"),  # 绿
]


func _ready() -> void:
	_setup_input_actions()
	_setup_game()
	_connect_signals()


func _process(_delta: float) -> void:
	# 更新球体位置 (未发射时跟随挡板)
	if _state == GameState.READY and ball and not ball.is_launched():
		ball.position = Vector2(paddle.position.x, paddle.position.y - 20)

	# 按R重置游戏
	if Input.is_action_just_pressed("reset"):
		if _state in [GameState.GAME_OVER, GameState.VICTORY]:
			_reset_game()


func _setup_input_actions() -> void:
	"""设置输入动作 (如果不存在则创建)"""
	var input_map = InputMap

	if not input_map.has_action("move_left"):
		input_map.add_action("move_left")
		var key_a = InputEventKey.new()
		key_a.keycode = KEY_A
		input_map.action_add_event("move_left", key_a)

	if not input_map.has_action("move_right"):
		input_map.add_action("move_right")
		var key_d = InputEventKey.new()
		key_d.keycode = KEY_D
		input_map.action_add_event("move_right", key_d)

	if not input_map.has_action("launch"):
		input_map.add_action("launch")
		var key_space = InputEventKey.new()
		key_space.keycode = KEY_SPACE
		input_map.action_add_event("launch", key_space)

	if not input_map.has_action("reset"):
		input_map.add_action("reset")
		var key_r = InputEventKey.new()
		key_r.keycode = KEY_R
		input_map.action_add_event("reset", key_r)


func _setup_game() -> void:
	"""初始化游戏"""
	_score = 0
	_state = GameState.READY
	_update_ui()
	_generate_bricks()
	_setup_victory_particles()


func _connect_signals() -> void:
	"""连接信号"""
	# 死亡区域
	if death_zone:
		death_zone.body_entered.connect(_on_death_zone_entered)

	# 球体信号
	if ball:
		ball.brick_hit.connect(_on_brick_destroyed)


func _generate_bricks() -> void:
	"""生成砖块阵列"""
	# 清除现有砖块
	for child in bricks_container.get_children():
		child.queue_free()

	_brick_count = 0

	# 计算起始位置 (居中)
	var total_width = BRICK_COLS * (BRICK_WIDTH + BRICK_GAP) - BRICK_GAP
	var start_x = (800 - total_width) / 2 + BRICK_WIDTH / 2
	var start_y = 60

	# 创建砖块
	for row in range(BRICK_ROWS):
		for col in range(BRICK_COLS):
			var brick = _create_brick(
				start_x + col * (BRICK_WIDTH + BRICK_GAP),
				start_y + row * (BRICK_HEIGHT + BRICK_GAP),
				BRICK_COLORS[row]
			)
			bricks_container.add_child(brick)
			_brick_count += 1


func _create_brick(pos_x: float, pos_y: float, color: Color) -> StaticBody2D:
	"""创建单个砖块"""
	var brick = StaticBody2D.new()
	brick.position = Vector2(pos_x, pos_y)
	brick.add_to_group("brick")
	brick.collision_layer = 2  # 第2层，在球的 collision_mask=30 范围内
	brick.collision_mask = 0   # 砖块不需要主动检测其他物体

	# 碰撞形状
	var collision = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(BRICK_WIDTH, BRICK_HEIGHT)
	collision.shape = rect_shape
	brick.add_child(collision)

	# 视觉形状
	var visual = ColorRect.new()
	visual.size = Vector2(BRICK_WIDTH, BRICK_HEIGHT)
	visual.color = color
	visual.position = Vector2(-BRICK_WIDTH/2, -BRICK_HEIGHT/2)
	brick.add_child(visual)

	# 连接信号
	# (body_entered 仅适用于 Area2D，StaticBody2D 由球体碰撞检测处理)

	return brick


func _on_brick_destroyed(brick: Node) -> void:
	"""砖块被击中（由球体信号触发）"""
	if not is_instance_valid(brick) or not brick.is_in_group("brick"):
		return
	brick.remove_from_group("brick")
	brick.queue_free()
	_brick_count -= 1
	_score += 10
	_update_ui()

	# 检查胜利条件
	if _brick_count <= 0:
		_on_victory()


func _on_death_zone_entered(body: Node2D) -> void:
	"""球体掉落到底部"""
	if body.is_in_group("ball"):
		_on_game_over()


func _on_victory() -> void:
	"""游戏胜利"""
	_state = GameState.VICTORY
	message_label.text = "胜利! 按 R 重新开始"
	message_label.show()

	# 触发胜利礼花
	_trigger_victory_particles()


func _on_game_over() -> void:
	"""游戏失败"""
	_state = GameState.GAME_OVER
	message_label.text = "游戏结束! 按 R 重新开始"
	message_label.show()


func _reset_game() -> void:
	"""重置游戏"""
	# 重置球体
	ball.reset(Vector2(paddle.position.x, paddle.position.y - 20))

	# 重新生成砖块
	_generate_bricks()

	# 重置状态
	_score = 0
	_state = GameState.READY

	# 更新UI
	_update_ui()
	message_label.hide()


func _update_ui() -> void:
	"""更新UI显示"""
	if score_label:
		score_label.text = "分数: %d" % _score


func _setup_victory_particles() -> void:
	"""设置胜利粒子效果"""
	if victory_particles:
		victory_particles.emitting = false
		victory_particles.one_shot = true


func _trigger_victory_particles() -> void:
	"""触发胜利礼花"""
	if victory_particles:
		victory_particles.restart()
		victory_particles.emitting = true
