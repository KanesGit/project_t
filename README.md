# 🦖 Dino Runner

[English](#english) | [中文](#中文)

---

<a name="english"></a>
## English

A browser-based endless runner game built with **Godot 4.6**, exported to WebGL. Jump over obstacles, survive as long as possible, and compete on the global leaderboard.

**🎮 [Play Now](https://www.kanes.art/game/)**

### Gameplay

- Enter a nickname to start
- Press **Space**, **click**, or **tap** to jump
- Avoid cacti and birds — speed increases over time
- Your score is submitted automatically when you die
- Top 10 leaderboard is shown after each run

### Tech Stack

| Layer | Technology |
|---|---|
| Game engine | Godot 4.6 |
| Export target | HTML5 / WebGL |
| Backend API | [dino-runner-server](https://github.com/KanesGit/dino-runner-server) |

### Project Structure

```
dino-runner/
├── main.gd              # Game logic, UI, physics, HTTP
├── dino.gd              # Dino character (animation + rendering)
├── main.tscn            # Main scene entry point
├── project.godot        # Godot project config
├── export_presets.cfg   # Web export settings
├── icon.svg             # App icon
└── deploy/
    ├── setup.sh                  # Server setup script
    └── dino-runner.nginx.conf    # Nginx reverse proxy config
```

### Development

1. Install [Godot 4.6](https://godotengine.org/download)
2. Open `project.godot` in the Godot editor
3. Update `SERVER_URL` in `main.gd` to point to your backend

```gdscript
const SERVER_URL := "https://www.kanes.art"
```

4. Run with **F5** in the editor, or export to HTML5 via **Project → Export**

### Deployment

The game is served as a static web export. See [`deploy/setup.sh`](deploy/setup.sh) for the full server setup and [`deploy/dino-runner.nginx.conf`](deploy/dino-runner.nginx.conf) for the Nginx config.

The backend leaderboard API lives in [dino-runner-server](https://github.com/KanesGit/dino-runner-server).

---

<a name="中文"></a>
## 中文

基于 Chrome 离线恐龙游戏灵感，使用 **Godot 4.6** 开发的无尽跑酷游戏。

**🎮 [立即游玩](https://www.kanes.art/game/)**

### 游戏玩法

- 输入昵称开始游戏
- 按**空格键**或**点击屏幕**跳跃
- 躲避仙人掌和飞鸟障碍物
- 游戏速度随时间加快——挑战你的极限！
- 游戏结束后自动提交分数并显示 TOP 10 排行榜

### 功能特色

- 🦕 像素风格恐龙，双帧跑步动画
- 🔊 程序生成音效（无需外部音频文件）
- 📊 顶部实时分数显示 + 个人最高纪录
- 🏆 昵称输入 + 前 10 名排行榜
- 📱 支持桌面与移动端浏览器

### 技术栈

| 层级 | 技术 |
|------|------|
| 游戏引擎 | Godot 4.6 |
| 开发语言 | GDScript |
| 导出格式 | HTML5 / WebAssembly |
| 排行榜后端 | Node.js + Express + SQLite |
| 部署平台 | 腾讯云轻量服务器 |

### 本地开发

1. 安装 [Godot 4.6](https://godotengine.org/download)
2. 用 Godot 打开 `project.godot` 文件
3. 修改 `main.gd` 中的 `SERVER_URL`：

```gdscript
const SERVER_URL := "https://www.kanes.art"
```

4. 按 **F5** 运行，或通过 **项目 → 导出** 导出 HTML5 版本

### API 接口

排行榜后端提供以下接口：

| 方法 | 路径 | 说明 |
|------|------|------|
| `POST` | `/api/score` | 提交分数 `{ name, score }` |
| `GET` | `/api/leaderboard` | 获取前 10 名 |

---

## Version History

### v1.0.0 (2026-03-23)
- 🎉 First release
- ✅ Core gameplay
- ✅ Leaderboard system
- ✅ Production deployment

## License

MIT