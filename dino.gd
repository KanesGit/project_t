extends Node2D

# ── 常數 ──────────────────────────────────────────────
const PS     := 4                          # 每格像素大小（4×4 實際像素）
const BODY_C := Color(0.15, 0.15, 0.15)   # 身體顏色
const EYE_C  := Color(0.90, 0.90, 0.90)   # 眼睛顏色
const DEAD_C := Color(0.78, 0.12, 0.12)   # 死亡顏色（紅）

# ── 像素藝術：10 欄 × 13 列（X=身體 E=眼睛 .=透明）──
#   恐龍面向右方，頭在右側（欄 4-9），尾在左側（欄 0-3）
const FRAME_0 := [
	"....XXXXXX",   # 0  頭頂
	"...XXXXXXX",   # 1  頭
	"...XXXEXXX",   # 2  頭（E=眼睛）
	"..XXXXXXXX",   # 3  下顎/頸
	".XXXXXXXXX",   # 4  上身
	"XXXXXXXXXX",   # 5  身體
	"XXXXXXXXX.",   # 6  下身+尾
	"XXXXXXX...",   # 7  尾巴
	"..XXXXX...",   # 8  髖部
	"..XX.XX...",   # 9  大腿
	".XXX..X...",   # 10 步態 A：左腿前
	".XXX..X...",   # 11
	".XXX......",   # 12 腳 A
]

const FRAME_1 := [
	"....XXXXXX",   # 0
	"...XXXXXXX",   # 1
	"...XXXEXXX",   # 2
	"..XXXXXXXX",   # 3
	".XXXXXXXXX",   # 4
	"XXXXXXXXXX",   # 5
	"XXXXXXXXX.",   # 6
	"XXXXXXX...",   # 7
	"..XXXXX...",   # 8
	"..XX.XX...",   # 9
	"..XX.XXX..",   # 10 步態 B：右腿前
	"..XX.XXX..",   # 11
	".....XXX..",   # 12 腳 B
]

# ── 狀態 ──────────────────────────────────────────────
var _frame     := 0
var _anim_t    := 0.0
var _dead      := false
var _animating := false


# ── 公開 API ──────────────────────────────────────────
func set_playing(v: bool) -> void:
	_animating = v
	if not v:
		_frame  = 0
		_anim_t = 0.0
	queue_redraw()


func set_dead(v: bool) -> void:
	_dead  = v
	_frame = 0
	queue_redraw()


# ── 動畫更新 ──────────────────────────────────────────
func _process(delta: float) -> void:
	if not _animating:
		return
	_anim_t += delta
	if _anim_t >= 0.12:
		_anim_t = 0.0
		_frame  = 1 - _frame
		queue_redraw()


# ── 像素繪製 ──────────────────────────────────────────
func _draw() -> void:
	var bc         := DEAD_C if _dead else BODY_C
	var frame_data := FRAME_1 if _frame == 1 else FRAME_0
	for row in frame_data.size():
		var line: String = frame_data[row]
		for col in line.length():
			match line[col]:
				"X":
					draw_rect(Rect2(col * PS, row * PS, PS, PS), bc)
				"E":
					draw_rect(Rect2(col * PS, row * PS, PS, PS), EYE_C)
