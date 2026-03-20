# 🦕 Dino Runner

A browser-based endless runner game inspired by Chrome's offline dinosaur game, built with **Godot 4.6** and exported to Web.

**👉 [Play Now](https://kanesgit.github.io/project_t/)**

---

## Gameplay

- Press **Space** or **Click** to jump
- Avoid cacti and birds
- Speed increases over time — how far can you go?

## Features

- Pixel art dinosaur with 2-frame running animation
- Procedural sound effects (no audio files needed)
- Real-time score display + personal best tracking
- Nickname input + **Top 10 leaderboard** (requires backend server)
- Works on desktop and mobile browsers

## Controls

| Action | Input |
|--------|-------|
| Jump | Space / Click / Tap |
| Start / Retry | Space / Click / Tap |

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Game Engine | Godot 4.6 |
| Language | GDScript |
| Export | HTML5 / WebAssembly |
| Leaderboard Server | Node.js + Express + SQLite |
| Hosting | GitHub Pages |

## Local Development

### Run the game
Open `dino-runner/project.godot` in **Godot 4.x** and press **F5**.

### Run the leaderboard server
```bash
cd dino-runner/server
npm install
npm start
```
Server runs at `http://localhost:3000`

### Export to Web
```bash
/path/to/Godot --headless --export-release "Web" build/web/index.html
```

## Project Structure

```
dino-runner/
├── main.gd              # Game logic, UI, HTTP requests
├── dino.gd              # Pixel art sprite + animation
├── main.tscn            # Main scene
├── project.godot        # Godot project config
├── export_presets.cfg   # Web export settings
└── server/
    ├── server.js        # Express API (score submit + leaderboard)
    └── package.json
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/score` | Submit `{ name, score }` |
| `GET` | `/api/leaderboard` | Get top 10 scores |

---

Built with [Godot Engine](https://godotengine.org)
