extends Node2D

# ── 常數 ──────────────────────────────────────────────
const SW         := 800
const SH         := 300
const GROUND_Y   := 248
const GRAVITY    := 2200.0
const JUMP_VY    := -730.0
const BASE_SPD   := 280.0
const MAX_SPD    := 750.0
const DINO_W     := 40
const DINO_H     := 52
const DINO_X     := 80
## 修改為你的伺服器地址（部署後換成正式域名）
const SERVER_URL := "http://43.156.79.28:3000"

const DinoScene  = preload("res://dino.gd")

# 返回支援中文的 SystemFont（瀏覽器字體）
func _cjk_font() -> SystemFont:
	var f := SystemFont.new()
	f.font_names = PackedStringArray([
		"PingFang SC", "Noto Sans CJK SC", "Microsoft YaHei",
		"Hiragino Sans GB", "WenQuanYi Micro Hei", "sans-serif"
	])
	return f

# ── 節點引用 ──────────────────────────────────────────
var ui:            CanvasLayer
var dino:          Node2D
var score_lbl:     Label
var hi_lbl:        Label
var jump_sfx:      AudioStreamPlayer
var die_sfx:       AudioStreamPlayer
# 暱稱輸入面板
var name_panel:    Panel
var name_input:    LineEdit
# 排行榜面板
var lb_panel:      Panel
var lb_name_cols:  Array = []
var lb_score_cols: Array = []
var lb_this_score: Label
# HTTP
var http_submit:   HTTPRequest
var http_fetch:    HTTPRequest

# ── 遊戲狀態 ──────────────────────────────────────────
var obstacles:   Array = []
var dino_vy      := 0.0
var on_ground    := true
var speed        := BASE_SPD
var score        := 0.0
var hi_score     := 0.0
var player_name  := ""
var state        := "name_input"   # name_input | play | dead | leaderboard
var spawn_t      := 1.2


# ═══════════════════════════════════════════════════════
func _ready() -> void:
	_build_scene()


func _build_scene() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.96, 0.96, 0.96)
	bg.size  = Vector2(SW, SH)
	add_child(bg)

	var gnd := ColorRect.new()
	gnd.color    = Color(0.33, 0.33, 0.33)
	gnd.position = Vector2(0, GROUND_Y)
	gnd.size     = Vector2(SW, 3)
	add_child(gnd)

	dino          = DinoScene.new()
	dino.position = Vector2(DINO_X, GROUND_Y - DINO_H)
	add_child(dino)

	ui = CanvasLayer.new()
	add_child(ui)

	# 頂部居中：當局實時分數
	score_lbl                      = Label.new()
	score_lbl.position             = Vector2(0, 8)
	score_lbl.size                 = Vector2(SW, 36)
	score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_lbl.add_theme_font_size_override("font_size", 32)
	score_lbl.add_theme_color_override("font_color", Color(0.15, 0.15, 0.15))
	score_lbl.text    = "00000"
	score_lbl.visible = false
	ui.add_child(score_lbl)

	# 右上：最高紀錄
	hi_lbl                         = Label.new()
	hi_lbl.position                = Vector2(SW - 200, 12)
	hi_lbl.size                    = Vector2(180, 28)
	hi_lbl.horizontal_alignment    = HORIZONTAL_ALIGNMENT_RIGHT
	hi_lbl.add_theme_font_size_override("font_size", 18)
	hi_lbl.add_theme_color_override("font_color", Color(0.55, 0.55, 0.55))
	hi_lbl.visible = false
	ui.add_child(hi_lbl)

	_build_name_panel()
	_build_lb_panel()

	jump_sfx        = AudioStreamPlayer.new()
	jump_sfx.stream = _make_sfx("jump")
	add_child(jump_sfx)

	die_sfx        = AudioStreamPlayer.new()
	die_sfx.stream = _make_sfx("die")
	add_child(die_sfx)

	http_submit         = HTTPRequest.new()
	http_submit.timeout = 5.0
	http_submit.request_completed.connect(_on_submit_done)
	add_child(http_submit)

	http_fetch         = HTTPRequest.new()
	http_fetch.timeout = 5.0
	http_fetch.request_completed.connect(_on_fetch_done)
	add_child(http_fetch)


# ── 暱稱輸入面板 ──────────────────────────────────────
func _build_name_panel() -> void:
	name_panel          = Panel.new()
	name_panel.position = Vector2(200, 30)
	name_panel.size     = Vector2(400, 240)
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.12, 0.12, 0.14, 0.97)
	s.set_corner_radius_all(12)
	name_panel.add_theme_stylebox_override("panel", s)
	ui.add_child(name_panel)

	var title := Label.new()
	title.text                 = "DINO RUNNER"
	title.position             = Vector2(0, 22)
	title.size                 = Vector2(400, 38)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color.WHITE)
	name_panel.add_child(title)

	var sub := Label.new()
	sub.text                 = "Enter your nickname"
	sub.position             = Vector2(0, 74)
	sub.size                 = Vector2(400, 28)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 17)
	sub.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75))
	sub.add_theme_font_override("font", _cjk_font())
	name_panel.add_child(sub)

	name_input                  = LineEdit.new()
	name_input.position         = Vector2(80, 112)
	name_input.size             = Vector2(240, 36)
	name_input.placeholder_text = "Max 12 chars"
	name_input.max_length       = 12
	name_input.add_theme_font_size_override("font_size", 18)
	name_input.text_submitted.connect(_on_name_submitted)
	name_panel.add_child(name_input)

	var btn := Button.new()
	btn.text     = "Start Game"
	btn.position = Vector2(125, 165)
	btn.size     = Vector2(150, 40)
	btn.add_theme_font_size_override("font_size", 18)
	btn.add_theme_font_override("font", _cjk_font())
	btn.pressed.connect(_on_start_pressed)
	name_panel.add_child(btn)


# ── 排行榜面板 ────────────────────────────────────────
func _build_lb_panel() -> void:
	lb_panel          = Panel.new()
	lb_panel.position = Vector2.ZERO
	lb_panel.size     = Vector2(SW, SH)
	lb_panel.visible  = false
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.05, 0.05, 0.07, 0.97)
	lb_panel.add_theme_stylebox_override("panel", s)
	ui.add_child(lb_panel)

	var title := Label.new()
	title.text                 = "TOP 10  LEADERBOARD"
	title.position             = Vector2(0, 8)
	title.size                 = Vector2(SW, 26)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(1.0, 0.82, 0.1))
	lb_panel.add_child(title)

	lb_this_score          = Label.new()
	lb_this_score.position = Vector2(SW - 190, 8)
	lb_this_score.size     = Vector2(170, 26)
	lb_this_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lb_this_score.add_theme_font_size_override("font_size", 16)
	lb_this_score.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	lb_this_score.add_theme_font_override("font", _cjk_font())
	lb_panel.add_child(lb_this_score)

	var div := ColorRect.new()
	div.color    = Color(0.28, 0.28, 0.35)
	div.position = Vector2(30, 36)
	div.size     = Vector2(SW - 60, 1)
	lb_panel.add_child(div)

	for i in 10:
		var y := 40 + i * 22

		var rank := Label.new()
		rank.text     = "#%d" % (i + 1)
		rank.position = Vector2(40, y)
		rank.size     = Vector2(38, 20)
		rank.add_theme_font_size_override("font_size", 14)
		rank.add_theme_color_override("font_color", _rank_color(i))
		lb_panel.add_child(rank)

		var n_lbl := Label.new()
		n_lbl.position = Vector2(88, y)
		n_lbl.size     = Vector2(500, 20)
		n_lbl.add_theme_font_size_override("font_size", 14)
		n_lbl.add_theme_color_override("font_color", Color(0.88, 0.88, 0.88))
		lb_panel.add_child(n_lbl)
		lb_name_cols.append(n_lbl)

		var s_lbl := Label.new()
		s_lbl.position             = Vector2(640, y)
		s_lbl.size                 = Vector2(110, 20)
		s_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		s_lbl.add_theme_font_size_override("font_size", 14)
		s_lbl.add_theme_color_override("font_color", Color(0.88, 0.88, 0.88))
		lb_panel.add_child(s_lbl)
		lb_score_cols.append(s_lbl)

	var btn := Button.new()
	btn.text     = "Play Again"
	btn.position = Vector2(SW / 2.0 - 105, 266)
	btn.size     = Vector2(210, 28)
	btn.add_theme_font_size_override("font_size", 15)
	btn.add_theme_font_override("font", _cjk_font())
	btn.pressed.connect(_on_replay_pressed)
	lb_panel.add_child(btn)


func _rank_color(i: int) -> Color:
	match i:
		0: return Color(1.00, 0.84, 0.00)
		1: return Color(0.78, 0.78, 0.78)
		2: return Color(0.80, 0.50, 0.20)
		_: return Color(0.60, 0.60, 0.60)


# ── 暱稱面板回調 ──────────────────────────────────────
func _on_name_submitted(_text: String) -> void:
	_on_start_pressed()


func _on_start_pressed() -> void:
	var n       := name_input.text.strip_edges()
	player_name  = n if not n.is_empty() else "Anonymous"
	name_panel.visible = false
	score_lbl.visible  = true
	_start()


func _on_replay_pressed() -> void:
	lb_panel.visible   = false
	name_panel.visible = true
	score_lbl.visible  = false
	state = "name_input"


# ── 遊戲控制 ──────────────────────────────────────────
func _start() -> void:
	state     = "play"
	score     = 0.0
	speed     = BASE_SPD
	spawn_t   = 1.2
	dino_vy   = 0.0
	on_ground = true
	dino.position.y = GROUND_Y - DINO_H
	dino.set_dead(false)
	dino.set_playing(true)
	score_lbl.text = "00000"
	for o in obstacles:
		o.queue_free()
	obstacles.clear()


func _jump() -> void:
	if on_ground:
		dino_vy   = JUMP_VY
		on_ground = false
		jump_sfx.stop()
		jump_sfx.play()


func _die() -> void:
	state = "dead"
	dino.set_dead(true)
	dino.set_playing(false)
	die_sfx.play()
	if score > hi_score:
		hi_score = score
		hi_lbl.text    = "HI %05d" % int(hi_score)
		hi_lbl.visible = true
	_submit_score()


# ── HTTP：提交分數 → 拉取排行榜 ───────────────────────
func _submit_score() -> void:
	var body    := JSON.stringify({"name": player_name, "score": int(score)})
	var headers := ["Content-Type: application/json"]
	var err     := http_submit.request(
		SERVER_URL + "/api/score", headers, HTTPClient.METHOD_POST, body
	)
	if err != OK:
		_fetch_leaderboard()   # 提交失敗直接拉排行榜


func _on_submit_done(_result, _code, _headers, _body) -> void:
	_fetch_leaderboard()


func _fetch_leaderboard() -> void:
	var err := http_fetch.request(SERVER_URL + "/api/leaderboard")
	if err != OK:
		_show_leaderboard([])


func _on_fetch_done(_result, _code, _headers, body: PackedByteArray) -> void:
	var json := JSON.new()
	if json.parse(body.get_string_from_utf8()) == OK and json.data is Array:
		_show_leaderboard(json.data)
	else:
		_show_leaderboard([])


func _show_leaderboard(data: Array) -> void:
	lb_this_score.text = "%s  %05d" % [player_name, int(score)]
	for i in lb_name_cols.size():
		if i < data.size():
			lb_name_cols[i].text  = str(data[i].get("name", ""))
			lb_score_cols[i].text = "%05d" % int(data[i].get("score", 0))
		else:
			lb_name_cols[i].text  = "-"
			lb_score_cols[i].text = ""
	lb_panel.visible = true
	state = "leaderboard"


# ── 輸入（遊戲中跳躍）────────────────────────────────
func _input(event: InputEvent) -> void:
	if state != "play":
		return
	var go := false
	if event is InputEventKey and event.keycode == KEY_SPACE and event.pressed and not event.echo:
		go = true
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		go = true
	if event is InputEventScreenTouch and event.pressed:
		go = true
	if go:
		_jump()


# ── 主循環 ────────────────────────────────────────────
func _process(delta: float) -> void:
	if state != "play":
		return

	score  += delta * 10.0
	speed   = minf(BASE_SPD + score * 0.8, MAX_SPD)
	score_lbl.text = "%05d" % int(score)

	if not on_ground:
		dino_vy         += GRAVITY * delta
		dino.position.y += dino_vy * delta
		if dino.position.y >= GROUND_Y - DINO_H:
			dino.position.y = GROUND_Y - DINO_H
			dino_vy         = 0.0
			on_ground       = true

	spawn_t -= delta
	if spawn_t <= 0.0:
		_spawn()
		spawn_t = randf_range(0.8, 1.8) * (BASE_SPD / speed)

	var dino_r   := Rect2(dino.position + Vector2(4, 4), Vector2(DINO_W - 8, DINO_H - 8))
	var to_remove: Array = []

	for obs in obstacles:
		obs.position.x -= speed * delta
		var obs_r := Rect2(obs.position + Vector2(3, 3), obs.size - Vector2(6, 6))
		if dino_r.intersects(obs_r):
			_die()
			return
		if obs.position.x < -80:
			to_remove.append(obs)

	for obs in to_remove:
		obstacles.erase(obs)
		obs.queue_free()


# ── 生成障礙物 ────────────────────────────────────────
func _spawn() -> void:
	var obs   := ColorRect.new()
	obs.color  = Color(0.22, 0.22, 0.22)
	var is_bird := score > 250.0 and randf() < 0.35
	if is_bird:
		obs.size = Vector2(46, 24)
		var heights := [
			GROUND_Y - DINO_H - 8,
			GROUND_Y - DINO_H - 58,
			GROUND_Y - DINO_H - 98
		]
		obs.position = Vector2(SW + 10, float(heights[randi() % 3]))
	else:
		var h := randf_range(32.0, 66.0)
		obs.size     = Vector2(28, h)
		obs.position = Vector2(SW + 10, GROUND_Y - h)
	add_child(obs)
	obstacles.append(obs)


# ── 程序音效生成 ──────────────────────────────────────
func _make_sfx(type: String) -> AudioStreamWAV:
	var rate     := 22050
	var duration := 0.14 if type == "jump" else 0.22
	var n        := int(rate * duration)
	var data     := PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var t    := float(i) / rate
		var prog := float(i) / n
		var s    := 0.0
		if type == "jump":
			s = sin(TAU * lerpf(150.0, 480.0, prog) * t) * exp(-t * 14.0)
		else:
			s = (sin(TAU * lerpf(300.0, 60.0, prog) * t) * 0.65
				+ randf_range(-1.0, 1.0) * 0.35) * exp(-t * 9.0)
		var vi := int(clamp(s, -1.0, 1.0) * 32767)
		var vu := vi if vi >= 0 else vi + 65536
		data[i * 2]     = vu & 0xFF
		data[i * 2 + 1] = (vu >> 8) & 0xFF
	var wav      := AudioStreamWAV.new()
	wav.format   = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.stereo   = false
	wav.data     = data
	return wav
