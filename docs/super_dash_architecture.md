# Super Dash — Current Architecture

Audit snapshot for the cloned [Super Dash](https://github.com/flutter/super_dash) Flutter platformer. This document describes how the project is wired today, before any Chicken Soccer gameplay changes.

> **Note:** `docs/project_brief.md` is not present in this repo. Task context lives in `docs/tasks.md`.

---

## High-level stack

| Layer | Technology | Role |
|-------|------------|------|
| App shell | Flutter + Material | Menus, intro, score flow, settings, leaderboard |
| App state | `flutter_bloc` / `bloc` | `GameBloc` (in-run score/level), `ScoreBloc` (post-run flow) |
| Gameplay | Flame + Leap | Real-time runner, tiled maps, physics, collisions |
| Maps | `flame_tiled` + Tiled `.tmx` | Three section maps, object layers for spawn/items/enemies |
| Persistence | `shared_preferences` | Audio/settings toggles |
| Backend | Firebase Auth + Firestore | Anonymous auth, leaderboard entries |
| Local packages | `packages/app_ui`, `authentication_repository`, `leaderboard_repository` | Shared UI theme/widgets and data access |

---

## Entry points

| File | Purpose |
|------|---------|
| `lib/main_dev.dart` | Default dev entry — Firebase dev config, bootstraps `App` |
| `lib/main_prod.dart` | Production Firebase config and share URL |
| `lib/main_tester.dart` | Sets `App(isTesting: true)` → launches `MapTesterView` instead of intro |
| `lib/bootstrap.dart` | `BlocObserver`, error logging, `runApp` wrapper |

**Boot sequence**

1. `main_*.dart` initializes Firebase, `SettingsController`, `AudioController`, `ShareController`, `LeaderboardRepository`.
2. `bootstrap()` runs the app with `AuthenticationRepository` (anonymous sign-in).
3. `App` (`lib/app/view/app.dart`) builds `MaterialApp` with `home: GameIntroPage` (or map tester).

---

## Main game flow

```
GameIntroPage
    │  Play
    ▼
Game (BlocProvider<GameBloc>)
    └── GameView
            ├── GameWidget → SuperDashGame (Flame)
            ├── ScoreLabel (Flutter HUD)
            ├── AudioButton
            └── overlay: tapToJump
                    │
        tap / spacebar → start walking / jump
                    │
        collect items → GameScoreIncreased
        hit enemy / hazard → death → gameOver()
        reach section end → sectionCleared() → next map
                    │
        gameOver() → Navigator.push(ScorePage)
                    │
ScorePage (FlowBuilder)
    gameOver → inputInitials → scoreOverview → leaderboard (optional)
    Play Again → pops back to intro/game
```

### Intro (`lib/game_intro/`)

- `GameIntroPage` — logo, headline, Play button navigates via `Game.route()`.
- Bottom bar: audio toggle, leaderboard, info dialog, how-to-play instructions overlay.
- Mobile web shows a download prompt instead of Play.

### Active run (`lib/game/view/game_view.dart`)

- `Game` creates a scoped `GameBloc`.
- `GameWidget.controlled` hosts `SuperDashGame` with one Flame overlay (`tapToJump`).
- Flutter widgets sit above the game canvas: `ScoreLabel` (top), `AudioButton` (bottom).

### Post-run (`lib/score/`)

- `SuperDashGame.gameOver()` resets run state, reloads map A, then `Navigator.push(ScorePage.route(score: …))`.
- `ScoreBloc` drives a `flow_builder` flow: game over → initials → overview → leaderboard.
- Leaderboard writes to Firestore via `LeaderboardRepository`.

---

## Flame game class: `SuperDashGame`

**File:** `lib/game/super_dash_game.dart`

Extends **`LeapGame`** (from the `leap` package) with `TapDetector` and `HasKeyboardHandlerComponents`.

### Responsibilities

| Concern | Implementation |
|---------|----------------|
| Map loading | `loadWorldAndMap()` with prefix `assets/map/`; cycles `_sections` A → B → C |
| Tile size | 64 px |
| Camera | Fixed 592×1024 viewport; follows `PlayerCameraAnchor` |
| Input fan-out | `_inputListener` list; tap and spacebar trigger listeners |
| Entity spawning | `ObjectGroupProximityBuilder` for `items` and `enemies` object layers |
| Section transitions | `sectionCleared()` → score bonus + `GameSectionCompleted` + `_loadNewSection()` |
| Death / restart | `gameOver()` → bloc reset, entity cleanup, delayed map/player respawn, score navigation |
| Decorations | `TreeSign`, `TreeHouseFront` on section A / last section |

### Map sections

| Index | File | Background gradient |
|-------|------|---------------------|
| 0 | `flutter_runnergame_map_A.tmx` | lavender / mint |
| 1 | `flutter_runnergame_map_B.tmx` | pink / purple |
| 2 | `flutter_runnergame_map_C.tmx` | dark blue |

`GameBloc.state.currentSection` tracks the active map; `currentLevel` increments after completing all three.

---

## Player logic

### Core entity: `Player`

**File:** `lib/game/entities/player.dart`

- Extends **`JumperCharacter<SuperDashGame>`** (Leap) — auto-run platformer with jump physics.
- Constants: `speed = 5.0`, `jumpImpulse = 0.6`, `initialHealth = 1`.
- Spawn/respawn positions come from Tiled object layers `spawn` and `respawn`.

### Behaviors (flame_behaviors)

| Behavior | File | Role |
|----------|------|------|
| `PlayerControllerBehavior` | `lib/game/behaviors/player_controller_behavior.dart` | Input: first tap starts walk; ground tap jumps; golden feather enables double jump |
| `PlayerStateBehavior` | `lib/game/behaviors/player_state_behavior.dart` | Swaps sprite animations per `DashState` (idle, run, jump, death, phoenix variants) |

### Camera

**File:** `lib/game/components/player_camera_anchor.dart`

- `PlayerCameraAnchor` clamps camera X/Y within level bounds with smooth vertical tracking via `CameraBounds`.

### Player update loop (summary)

1. **Section clear** — X passes threshold (last section: full width; others: width − 15 tiles).
2. **Death** — health → 0 (enemy hit) or stuck timer (walking but not moving for 1s) → death animation → `gameOver()` after 1.4s.
3. **Hazards** — `hazard` collision tag: death unless golden feather (then respawn).
4. **Items** — pickup SFX, score event, `ItemEffect` VFX, entity removed.
5. **Enemies** — damage or feather-consuming respawn (same as hazards).

### Power-up: golden feather

- From `ItemType.goldenFeather` pickup → `addPowerUp()`.
- Enables phoenix animations and double jump.
- Consumed on fatal hit or hazard instead of dying.

---

## World setup

### Tiled maps (`assets/map/`)

Maps are authored in Tiled and loaded by Leap/Flame. Key object/tile layers used in code:

| Layer name | Used by |
|------------|---------|
| `spawn` | `Player.loadSpawnPoint()` |
| `respawn` | `Player.loadRespawnPoints()` |
| `items` | `ObjectGroupProximityBuilder` → `Item` |
| `enemies` | `ObjectGroupProximityBuilder` → `Enemy` |

Collision geometry and hazard tags come from Leap’s tiled collision parsing (tile layers + properties).

### Proximity spawning

**File:** `lib/game/components/object_group_proximity_spawner.dart`

- Reads all objects from a named object group once at load.
- Spawns `Item` / `Enemy` components when the player is within `1.5 × cameraViewport.width`.
- Despawns entities that fall outside that range (performance for long maps).

### Enemies

**File:** `lib/game/entities/enemy.dart`

- `EnemyType` from Tiled property `Type` (Butterfly, Beetle, Bee, etc.).
- Optional `Path` property → `FollowPathBehavior` (SVG-like path via `pathxp`).
- `Fly` property → static vs moving collision.
- Sprites loaded from `assets/map/anim/spritesheet_enemy_*.png`.

### Items / collectibles

**File:** `lib/game/entities/item.dart`

| `ItemType` | Tiled `Type` | Points | Visual |
|------------|--------------|--------|--------|
| `acorn` | (default) | 10 | `tile_items_v2` spritesheet + bob animation |
| `egg` | `Egg` | 1000 | `spritesheet_item_egg.png` |
| `goldenFeather` | `Feather` | 0 | `spritesheet_item_feather.png` |

### World decorations

- `TreeHouseFront` — re-renders last tiled layer in front of player on sections A/C.
- `TreeSign` — positioned sign component on section A.

---

## Score logic

### In-run: `GameBloc`

**Files:** `lib/game/bloc/game_bloc.dart`, `game_state.dart`, `game_event.dart`

| Event | Effect |
|-------|--------|
| `GameScoreIncreased(by)` | `score += by` |
| `GameScoreDecreased(by)` | `score -= by` (defined, rarely used) |
| `GameSectionCompleted` | Advance `currentSection` or wrap to 0 and `currentLevel++` |
| `GameOver` | Reset to `GameState.initial()` (score 0, section 0, level 1) |

**Score sources today**

- Acorn pickup: **+10** (`ItemType.acorn`)
- Egg pickup: **+1000** (`ItemType.egg`)
- Section complete: **+1000 × currentLevel** (`SuperDashGame.sectionCleared()`)

### Post-run: `ScoreBloc`

**Files:** `lib/score/bloc/score_bloc.dart`, `score_state.dart`

- Receives final score as constructor arg (snapshot at game over).
- Validates 3-letter initials, blacklist check, submits to Firestore.
- `FlowBuilder` pages in `lib/score/routes/routes.dart`.

### HUD display

**File:** `lib/game/widgets/score_label.dart`

- `BlocSelector` on `GameBloc.state.score`.
- Localized label via `l10n.gameScoreLabel(score)` with trophy image.

---

## HUD and overlays

| UI | Type | Location |
|----|------|----------|
| Score | Flutter widget | `ScoreLabel` in `GameView` stack |
| Tap to start / jump hint | Flame overlay | `tapToJump` → `TapToJumpOverlay` |
| Audio mute | Flutter widget | `AudioButton` from `game_intro` |
| Game over | Full-screen Flutter page | `GameOverPage` in score flow |
| Instructions | Flutter overlay | `game_instructions` module from intro |

Flame overlays are registered in `GameView`:

```dart
overlayBuilderMap: {
  'tapToJump': (context, game) => const TapToJumpOverlay(),
},
initialActiveOverlays: const ['tapToJump'],
```

Removed on first tap or spacebar in `SuperDashGame`.

---

## Asset wiring

### `pubspec.yaml` asset bundles

```yaml
assets:
  - assets/images/      # UI: logos, backgrounds, instructions, trophy
  - assets/map/         # .tmx level files
  - assets/map/anim/    # character/enemy/item sprite sheets
  - assets/map/tiles/   # tileset images
  - assets/map/objects/ # item/enemy tileset PNGs (e.g. tile_items_v2.png)
  - assets/music/
  - assets/sfx/
```

### In-game image prefix

`SuperDashGame` sets `Images(prefix: 'assets/map/')` for Flame gameplay assets. UI images use Flutter asset paths directly or via **`lib/gen/assets.gen.dart`** (FlutterGen).

### Animation loading patterns

1. **Player states** — `PlayerStateBehavior` loads sequenced animations from `anim/spritesheet_dash_*.png` and `spritesheet_phoenixDash_*.png`.
2. **Enemies / items** — entity `onLoad()` loads type-specific sheets under `assets/map/anim/`.
3. **Acorns** — static tiles from `objects/tile_items_v2.png` via `itemsSpritesheet` built in `SuperDashGame.onLoad()`.

### Audio

**File:** `lib/audio/audio.dart`

- Music: shuffled playlist from `lib/audio/songs.dart` (`assets/music/`).
- SFX map: jump, footsteps, pickups, feather — paths under `assets/sfx/`.
- Controlled by `AudioController` + `SettingsController` (persisted).

---

## Project layout (game-relevant)

```
lib/
├── main_dev.dart / main_prod.dart / main_tester.dart
├── bootstrap.dart
├── app/view/app.dart                 # MaterialApp root
├── game_intro/                       # Intro, instructions, bottom bar buttons
├── game/
│   ├── super_dash_game.dart          # Flame/Leap game root
│   ├── view/game_view.dart           # GameWidget + HUD stack
│   ├── entities/                     # Player, Enemy, Item
│   ├── behaviors/                    # Input, animation state, path follow
│   ├── components/                   # Camera, spawners, effects, decorations
│   ├── bloc/                         # GameBloc (in-run state)
│   └── widgets/                      # ScoreLabel, TapToJumpOverlay, GameBackground
├── score/                            # Post-run flow (game over, initials, leaderboard)
├── audio/                            # Music + SFX controller
├── settings/                         # Settings persistence
├── leaderboard/                      # Leaderboard UI + bloc
└── gen/assets.gen.dart               # Generated UI asset references

assets/
├── images/                           # Non-gameplay UI art
└── map/                              # Tiled maps + gameplay sprites

packages/
├── app_ui/                           # Shared buttons, theme, layout helpers
├── authentication_repository/
└── leaderboard_repository/
```

---

## Key dependencies for gameplay

| Package | Usage |
|---------|--------|
| `flame` | Game loop, components, camera, overlays |
| `leap` (git `vgv` fork) | `LeapGame`, `JumperCharacter`, tiled collision, map load/unload |
| `flame_tiled` | Parse `.tmx`, tilesets, object groups |
| `flame_behaviors` | `Behavior<T>` pattern for player/enemy logic |
| `pathxp` | Enemy patrol paths from Tiled `Path` strings |

See `docs/setup_notes.md` for the CS-000 dependency resolution (`leap` vgv + pub `flame_tiled`).

---

## Debug / dev tools

- **Map tester** (`lib/map_tester/`) — `main_tester.dart` entry; `SuperDashGame(inMapTester: true)` shows FPS and camera bounds.
- **Cheat helpers** on `SuperDashGame`: `toggleInvincibility()`, `teleportPlayerToEnd()`, `showHitBoxes()`, `addCameraDebugger()`.

---

## Chicken Soccer migration touchpoints

Areas most likely to change in upcoming tasks (CS-002+):

| Area | Current location |
|------|------------------|
| Visible branding | `GameIntroPage`, l10n, `pubspec.yaml` name |
| Player character | `Player`, `PlayerStateBehavior`, dash/phoenix sprite sheets |
| Collectibles / obstacles | `Item`, `Enemy`, Tiled object layers, tilesets |
| Scoring | `GameBloc`, `ItemType.points`, `sectionCleared` bonus |
| HUD / game over | `ScoreLabel`, `GameOverPage`, l10n strings |
| New mechanics (kick/goals) | `PlayerControllerBehavior`, new components/events |

No gameplay code was modified for this audit.
