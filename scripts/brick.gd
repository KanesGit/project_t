## Brick.gd - 砖块控制器
## 砖块状态管理，处理被球体击中时的消除逻辑

extends Area2D

# 信号
signal brick_destroyed(brick: Node)

# 砖块尺寸
const BRICK_WIDTH := 64.0
const BRICK_HEIGHT := 24.0

# 是否已被消除
var _is_destroyed := false


func _ready() -> void:
	# 连接自身信号
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	"""当球体进入砖块区域时触发"""
	if body.is_in_group("ball"):
		hit()


func hit() -> void:
	"""被击中，消除砖块"""
	if _is_destroyed:
		return

	_is_destroyed = true
	brick_destroyed.emit(self)
	queue_free()
