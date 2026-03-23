# Dino Runner

A browser-based endless runner game built with **Godot 4.6**, exported to WebGL. Jump over obstacles, survive as long as possible, and compete on the global leaderboard.

## Gameplay

- Enter a nickname to start
- Press **Space**, **click**, or **tap** to jump
- Avoid cacti and birds — speed increases over time
- Your score is submitted automatically when you die
- Top 10 leaderboard is shown after each run

## Tech Stack

| Layer | Technology |
|---|---|
| Game engine | Godot 4.6 |
| Export target | HTML5 / WebGL |
| Backend API | [dino-runner-server](https://github.com/KanesGit/dino-runner-server) |

## Project Structure

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

## Development

1. Install [Godot 4.6](https://godotengine.org/download)
2. Open `project.godot` in the Godot editor
3. Update `SERVER_URL` in `main.gd` to point to your backend

```gdscript
const SERVER_URL := "http://your-server:3000"
```

4. Run with **F5** in the editor, or export to HTML5 via **Project → Export**

## Deployment

The game is served as a static web export. See [`deploy/setup.sh`](deploy/setup.sh) for the full server setup and [`deploy/dino-runner.nginx.conf`](deploy/dino-runner.nginx.conf) for the Nginx config.

The backend leaderboard API lives in [dino-runner-server](https://github.com/KanesGit/dino-runner-server).

## License

MIT
