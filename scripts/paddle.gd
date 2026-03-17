## Paddle.gd - 挡板控制器
## 玩家通过 A/D 键控制挡板左右移动

extends StaticBody2D

# 配置参数
const SPEED := 400.0
const PADDLE_WIDTH := 120.0

# 边界限制
var _min_x: float
var _max_x: float


func _ready() -> void:
	# 计算移动边界 (窗口宽度 - 挡板半宽 - 边距)
	var viewport_width = get_viewport_rect().size.x
	_min_x = PADDLE_WIDTH / 2 + 10
	_max_x = viewport_width - PADDLE_WIDTH / 2 - 10


func _process(delta: float) -> void:
	var velocity := 0.0

	# 读取输入
	if Input.is_action_pressed("move_left"):
		velocity = -SPEED
	elif Input.is_action_pressed("move_right"):
		velocity = SPEED

	# 移动挡板
	position.x += velocity * delta

	# 限制在边界内
	position.x = clamp(position.x, _min_x, _max_x)
