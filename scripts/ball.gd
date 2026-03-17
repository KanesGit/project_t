## Ball.gd - 球体控制器
## 球体物理运动、碰撞检测与反弹逻辑

extends CharacterBody2D

# 配置参数
const SPEED := 300.0
const BALL_RADIUS := 8.0

# 运动状态
var _is_launched := false
var _direction := Vector2.ZERO

# 信号
signal ball_fallen
signal brick_hit(brick: Node)


func _ready() -> void:
	# 初始静止于挡板上方
	_direction = Vector2.ZERO
	_is_launched = false


func _physics_process(delta: float) -> void:
	if not _is_launched:
		return

	# 计算速度
	velocity = _direction * SPEED

	# 移动并检测碰撞
	var collision = move_and_collide(velocity * delta)

	if collision:
		# 计算反弹方向
		_direction = _direction.bounce(collision.get_normal())

		# 获取碰撞体
		var collider = collision.get_collider()

		# 如果碰到挡板，根据碰撞位置调整反弹角度
		if collider and collider.is_in_group("paddle"):
			_adjust_bounce_by_paddle_position(collider, collision.get_position())

		# 如果碰到砖块，发出信号通知主场景
		if collider and collider.is_in_group("brick"):
			brick_hit.emit(collider)


func _process(_delta: float) -> void:
	# 按空格发射
	if not _is_launched and Input.is_action_just_pressed("launch"):
		launch()


func launch() -> void:
	"""发射球体"""
	if _is_launched:
		return

	_is_launched = true
	# 随机初始角度 (向上偏左或偏右)
	var angle = randf_range(-PI/4, PI/4) - PI/2
	_direction = Vector2(cos(angle), sin(angle)).normalized()


func reset(pos: Vector2) -> void:
	"""重置球体位置和状态"""
	position = pos
	_is_launched = false
	_direction = Vector2.ZERO


func is_launched() -> bool:
	return _is_launched


func _adjust_bounce_by_paddle_position(paddle: Node2D, collision_point: Vector2) -> void:
	"""根据挡板碰撞位置调整反弹角度"""
	# 计算碰撞点相对于挡板中心的偏移
	var relative_x = collision_point.x - paddle.position.x
	var paddle_half_width = 60.0  # 挡板半宽

	# 归一化到 -1 到 1
	var normalized_x = clamp(relative_x / paddle_half_width, -1.0, 1.0)

	# 根据位置计算反弹角度 (最大 ±60°)
	var max_angle = PI / 3  # 60度
	var bounce_angle = normalized_x * max_angle

	# 设置新的反弹方向 (向上)
	_direction = Vector2(sin(bounce_angle), -cos(bounce_angle)).normalized()
