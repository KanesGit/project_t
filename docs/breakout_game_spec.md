# 打砖块游戏 (Breakout) - 需求规格说明书

> **项目名称**: KaspGamer - Breakout
> **引擎版本**: Godot 4.6.1
> **开发语言**: GDScript
> **开发方法论**: 闪电式开发 (Lightning Development)

---

## 1. 项目概述

### 1.1 游戏概念

打砖块（Breakout）是一款经典的街机游戏。玩家控制底部挡板，反弹球体击碎上方的砖块阵列。当所有砖块被消除后，玩家获得胜利并触发庆祝特效。

### 1.2 核心价值主张

| 维度 | 描述 |
|------|------|
| **简单易上手** | 仅需 A/D 两键操作，零学习成本 |
| **即时反馈** | 球体碰撞、砖块破碎、胜利礼花提供明确视觉反馈 |
| **快节奏** | 单局游戏时长约 1-3 分钟，适合碎片化娱乐 |

### 1.3 目标用户

- 休闲游戏玩家
- 追求简单放松体验的用户
- 怀旧经典游戏爱好者

---

## 2. 游戏玩法规格

### 2.1 游戏规则

```
┌─────────────────────────────────────────┐
│  ████████████████████████████████████   │  ← 砖块区域
│  ████████████████████████████████████   │
│  ████████████████████████████████████   │
│  ████████████████████████████████████   │
│                                         │
│                   ●                     │  ← 球体
│                                         │
│            ═════════════                │  ← 挡板 (玩家控制)
│                                         │
└─────────────────────────────────────────┘
```

**规则定义**:

1. **初始状态**: 球体静止于挡板上方，等待发射
2. **发射机制**: 按空格键发射球体，以随机角度向上运动
3. **边界反弹**: 球体碰到左、右、上边界时反弹
4. **底部判定**: 球体触碰底部边界 = 游戏失败
5. **挡板反弹**: 球体触碰挡板时根据碰撞位置调整反弹角度
6. **砖块消除**: 球体触碰砖块 → 砖块消除 → 球体反弹
7. **胜利条件**: 消除所有砖块 → 触发胜利礼花

### 2.2 控制方案

| 按键 | 功能 | 说明 |
|------|------|------|
| `A` | 挡板左移 | 持续按住持续移动 |
| `D` | 挡板右移 | 持续按住持续移动 |
| `Space` | 发射球体 | 仅在球体静止状态有效 |
| `R` | 重新开始 | 游戏结束或胜利后可用 |

### 2.3 游戏参数

| 参数 | 值 | 说明 |
|------|-----|------|
| 游戏窗口 | 800 × 600 px | 固定分辨率 |
| 挡板宽度 | 120 px | 可根据难度调整 |
| 挡板移动速度 | 400 px/s | 每秒移动像素 |
| 球体直径 | 16 px | 碰撞半径 8px |
| 球体速度 | 300 px/s | 初始速度 |
| 砖块尺寸 | 64 × 24 px | 单块尺寸 |
| 砖块行数 | 4 行 | 可调整 |
| 砖块列数 | 12 列 | 可调整 |

---

## 3. 功能模块规格

### 3.1 模块架构

```
Main (主场景)
├── UI Layer (UI层)
│   ├── ScoreLabel (分数显示)
│   ├── GameStateLabel (游戏状态提示)
│   └── VictoryEffect (胜利礼花)
│
├── Game Layer (游戏层)
│   ├── Walls (边界墙)
│   │   ├── LeftWall
│   │   ├── RightWall
│   │   └── TopWall
│   │
│   ├── BrickContainer (砖块容器)
│   │   └── Brick × N (砖块实例)
│   │
│   ├── Ball (球体)
│   │
│   └── Paddle (挡板)
│
└── DeathZone (底部死亡区域)
```

### 3.2 场景结构

#### 3.2.1 主场景 (Main.tscn)

```
Node2D "Main"
├── ColorRect "Background"          # 背景
├── Node2D "Walls"                  # 边界墙组
│   ├── StaticBody2D "LeftWall"
│   ├── StaticBody2D "RightWall"
│   └── StaticBody2D "TopWall"
├── Area2D "DeathZone"              # 底部死亡区域
├── Node2D "Bricks"                 # 砖块容器
├── CharacterBody2D "Ball"          # 球体
├── StaticBody2D "Paddle"           # 挡板
├── CanvasLayer "UI"                # UI层
│   ├── Label "ScoreLabel"
│   └── Label "MessageLabel"
└── GPUParticles2D "VictoryParticles"  # 胜利礼花
```

### 3.3 脚本模块职责

| 脚本文件 | 绑定节点 | 职责 |
|----------|----------|------|
| `main.gd` | Main | 游戏状态管理、砖块生成、胜负判定 |
| `paddle.gd` | Paddle | 玩家输入处理、挡板移动 |
| `ball.gd` | Ball | 球体物理运动、碰撞检测 |
| `brick.gd` | Brick | 砖块状态、消除逻辑 |

---

## 4. 物理系统规格

### 4.1 碰撞层级 (Collision Layer)

| 层级 | 名称 | 用途 |
|------|------|------|
| 1 | ball | 球体专用 |
| 2 | paddle | 挡板专用 |
| 3 | brick | 砖块专用 |
| 4 | wall | 边界墙专用 |
| 5 | death_zone | 死亡区域 |

### 4.2 碰撞矩阵

| 碰撞体 | ball | paddle | brick | wall | death_zone |
|--------|:----:|:------:|:-----:|:----:|:----------:|
| ball   |  -   |   ✓    |   ✓   |  ✓   |     ✓      |
| paddle |  ✓   |   -    |   -   |  -   |     -      |
| brick  |  ✓   |   -    |   -   |  -   |     -      |

### 4.3 球体反弹机制

```gdscript
# 反弹角度计算 (基于挡板碰撞位置)
# 碰撞点越靠近挡板边缘，反弹角度越大

func calculate_bounce_angle(collision_point: Vector2, paddle_position: Vector2) -> Vector2:
    var relative_x = collision_point.x - paddle_position.x
    var normalized_x = relative_x / (paddle_width / 2)  # -1.0 到 1.0

    var angle = normalized_x * MAX_BOUNCE_ANGLE  # 最大反弹角度 ±60°
    var direction = Vector2(sin(angle), -cos(angle))

    return direction * ball_speed
```

---

## 5. 视觉设计规格

### 5.1 配色方案

| 元素 | 颜色代码 | 说明 |
|------|----------|------|
| 背景 | `#1a1a2e` | 深蓝黑色 |
| 挡板 | `#00d9ff` | 青色 |
| 球体 | `#ffffff` | 白色 |
| 砖块(行1) | `#ff6b6b` | 红色 |
| 砖块(行2) | `#feca57` | 橙色 |
| 砖块(行3) | `#48dbfb` | 蓝色 |
| 砖块(行4) | `#1dd1a1` | 绿色 |
| 边界墙 | `#2d3436` | 深灰色 |

### 5.2 胜利礼花特效

```
特效参数:
├── 类型: GPUParticles2D
├── 粒子数量: 200
├── 发射形状: 矩形 (覆盖全屏)
├── 颜色渐变: 彩虹色随机
├── 生命周期: 2.0 秒
├── 重力: 98 px/s² (向下)
├── 初始速度: 200-400 px/s
└── 持续时间: 一次爆发
```

---

## 6. 游戏状态流程

### 6.1 状态机

```
                    ┌─────────────┐
                    │   READY     │ ← 初始状态/重置后
                    └──────┬──────┘
                           │ Space
                           ▼
                    ┌─────────────┐
          ┌────────│  PLAYING    │────────┐
          │        └─────────────┘        │
          │                                 │
    球触底 ▼                           全消 ▼
    ┌─────────────┐               ┌─────────────┐
    │   GAME_OVER │               │   VICTORY   │
    └──────┬──────┘               └──────┬──────┘
           │                              │
           │ R                            │ R
           └──────────┬───────────────────┘
                      ▼
               (回到 READY 状态)
```

### 6.2 状态定义

| 状态 | 描述 | 可用操作 |
|------|------|----------|
| READY | 等待发射 | A/D 移动, Space 发射 |
| PLAYING | 游戏进行中 | A/D 移动 |
| GAME_OVER | 游戏失败 | R 重置 |
| VICTORY | 游戏胜利 | R 重置, 触发礼花 |

---

## 7. 闪电式开发计划

### 7.1 开发阶段划分

遵循 **MVP (最小可行产品)** 原则，分四个迭代周期：

```
迭代1: 核心玩法 (Phase 1 - MVP)
├── [1.1] 项目结构搭建
├── [1.2] 挡板实现 (Paddle)
├── [1.3] 球体实现 (Ball)
├── [1.4] 边界墙实现 (Walls)
└── [1.5] 碰撞系统验证
    交付物: 球体可在场景内反弹

迭代2: 砖块系统 (Phase 2)
├── [2.1] 砖块场景创建
├── [2.2] 砖块阵列生成
├── [2.3] 砖块消除逻辑
└── [2.4] 分数系统
    交付物: 可玩的游戏循环

迭代3: 游戏逻辑完善 (Phase 3)
├── [3.1] 游戏状态管理
├── [3.2] 发射机制
├── [3.3] 失败判定
└── [3.4] 胜利判定
    交付物: 完整的游戏流程

迭代4: 打磨与特效 (Phase 4)
├── [4.1] 胜利礼花特效
├── [4.2] UI 优化
├── [4.3] 视觉细节调整
└── [4.4] 最终测试
    交付物: 可发布的游戏
```

### 7.2 每阶段验收标准

| 阶段 | 验收标准 |
|------|----------|
| Phase 1 | 球体在场景内正常反弹，挡板可左右移动 |
| Phase 2 | 砖块可被消除，分数正确累计 |
| Phase 3 | 完整的游戏流程: 发射→游玩→胜负判定→重置 |
| Phase 4 | 胜利礼花正常触发，UI清晰，无明显BUG |

### 7.3 风险与应对

| 风险 | 概率 | 应对策略 |
|------|------|----------|
| 球体卡在角落 | 中 | 增加最小反弹角度限制 |
| 碰撞穿透 | 低 | 启用连续碰撞检测 (CCD) |
| 挡板速度过快 | 低 | 限制最大移动速度 |

---

## 8. 技术实现要点

### 8.1 Godot 节点选型

| 功能 | 节点类型 | 理由 |
|------|----------|------|
| 球体 | `CharacterBody2D` | 内置物理运动支持，适合主动移动物体 |
| 挡板 | `StaticBody2D` | 静态碰撞体，通过代码控制位置 |
| 砖块 | `Area2D` | 区域检测即可，无需物理模拟 |
| 边界墙 | `StaticBody2D` | 静态碰撞体 |
| 死亡区域 | `Area2D` | 仅需检测进入信号 |

### 8.2 关键代码模式

```gdscript
# 球体移动模式 (CharacterBody2D)
velocity = direction * speed
var collision = move_and_collide(velocity * delta)
if collision:
    var reflect = velocity.bounce(collision.get_normal())
    velocity = reflect

# 挡板移动模式 (StaticBody2D)
if Input.is_action_pressed("move_left"):
    position.x -= speed * delta
if Input.is_action_pressed("move_right"):
    position.x += speed * delta
position.x = clamp(position.x, min_x, max_x)
```

### 8.3 信号系统

```
信号连接图:

Brick.body_entered ──→ Main._on_brick_hit()
DeathZone.body_entered ──→ Main._on_ball_fallen()
Ball.wall_bounce ──→ (可选音效触发)
```

---

## 9. 文件结构规划

```
kasp-gamer/
├── project.godot
├── scenes/
│   ├── main.tscn              # 主场景
│   ├── ball.tscn              # 球体场景
│   ├── paddle.tscn            # 挡板场景
│   └── brick.tscn             # 砖块场景
├── scripts/
│   ├── main.gd                # 主控制脚本
│   ├── ball.gd                # 球体脚本
│   ├── paddle.gd              # 挡板脚本
│   └── brick.gd               # 砖块脚本
├── assets/
│   └── (预留资源目录)
└── README.md
```

---

## 10. 附录

### 10.1 术语表

| 术语 | 定义 |
|------|------|
| MVP | Minimum Viable Product，最小可行产品 |
| CCD | Continuous Collision Detection，连续碰撞检测 |
| Delta | 帧间隔时间，用于帧率无关的运动计算 |

### 10.2 参考资料

- [Godot 4 官方文档](https://docs.godotengine.org/en/stable/)
- [Godot 2D 物理系统教程](https://docs.godotengine.org/en/stable/tutorials/physics/index.html)

---

**文档版本**: v1.0
**创建日期**: 2026-03-17
**最后更新**: 2026-03-17
