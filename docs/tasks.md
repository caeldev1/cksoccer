## CS-000
Status: done
Title: Fix cloned project dependency resolution and restore a runnable baseline

Goal:
Resolve package version conflicts in the cloned CKSoccer project so flutter pub get and the default run flow work again.

Scope:
- Inspect pubspec.yaml and any dependency lock files.
- Identify the exact conflict between leap, flame_tiled, and tiled.
- Apply the smallest safe dependency change needed to restore a working baseline.
- Document the fix in docs/setup_notes.md.

Do not change:
- Gameplay behavior.
- App naming.
- Assets.
- Project structure unless needed for dependency resolution.

Affected files:
- pubspec.yaml
- pubspec.lock if regenerated
- docs/setup_notes.md

Definition of done:
- flutter pub get succeeds.
- The default app can start or at least build far enough to confirm dependency resolution is fixed.
- The dependency fix is documented.

Manual tests:
- Run flutter pub get
- Run flutter analyze if possible
- Run the default app target if possible

# Chicken Soccer Tasks

## CS-001
Status: done
Title: Audit the cloned CKSoccer project and document the current architecture

Goal:
Understand the existing CKSoccer structure before any gameplay changes.

Scope:
- Inspect the main entry points, Flame game class, level flow, HUD, assets, player logic, obstacle logic, and score logic.
- Write a short architecture summary in docs/super_dash_architecture.md.

Do not change:
- Gameplay behavior.
- Assets.
- Project configuration unless needed for inspection.

Affected files:
- docs/super_dash_architecture.md

Definition of done:
- A readable architecture summary exists.
- It explains where player logic, world setup, HUD, scoring, obstacles, and assets currently live.

Manual tests:
- Confirm the game still runs unchanged after documentation work.

## CS-002
Status: done
Title: Rebrand the project from Super Dash to CKSoccer

Goal:
Rename the game identity to CKSoccer (fork appropriation) without breaking the current build.

Scope:
- Rename Dart package from `super_dash` to `ck_soccer`.
- Rename `SuperDashGame` to `CKSoccer` and `super_dash_game.dart` to `ck_soccer.dart`.
- Replace user-facing references to Super Dash with CKSoccer.
- Update app title, basic menu copy, l10n keys, and visible labels where appropriate.

Do not change:
- Native store bundle/application ids (Firebase and store links still reference upstream).
- Core gameplay.

Affected files:
- pubspec.yaml
- lib/game/ck_soccer.dart (formerly super_dash_game.dart)
- package imports across lib/ and test/
- l10n arb and generated localization files
- platform display name files (AndroidManifest, Info.plist, web/index.html)
- share hashtag copy

Definition of done:
- The app launches with CKSoccer as the visible title.
- `SuperDashGame` is renamed to `CKSoccer` everywhere it is used.
- No visible Super Dash naming remains in the main user flow.

Manual tests:
- Run `flutter pub get`
- Run `flutter analyze`
- Launch the game and verify updated title and visible copy.

## CS-003
Status: pending
Title: Replace Dash character plan with Chicken player implementation scaffold

Goal:
Prepare the codebase to support a chicken main character instead of Dash.

Scope:
- Identify the current player component and create a replacement plan.
- Introduce a ChickenPlayer or equivalent game-specific player class, initially preserving existing movement behavior.
- Document required assets in docs/chicken_assets_plan.md.

Do not change:
- Final gameplay feel.
- HUD behavior.
- Random level systems.

Affected files:
- player-related game files
- docs/chicken_assets_plan.md

Definition of done:
- A chicken-oriented player class or scaffold exists.
- The game still runs.
- Required player animation assets are documented.

Manual tests:
- Verify the player still moves correctly after refactor.

## CS-004
Status: pending
Title: Convert the core fantasy from generic platform runner to chicken dribble runner

Goal:
Make the player feel like a chicken running with a soccer ball.

Scope:
- Attach or visually pair a ball with the player.
- Update idle/run presentation to imply dribbling.
- Keep controls simple and preserve current runner stability.

Do not change:
- Add kicking yet.
- Add goal events yet.

Affected files:
- player visual / animation files
- ball companion files if introduced

Definition of done:
- The player visibly reads as a chicken dribbling a ball during normal movement.

Manual tests:
- Verify the ball remains visually coherent during run, jump, and collision states.

## CS-005
Status: pending
Title: Replace world flavor and pickups with football-themed equivalents

Goal:
Shift the game’s visual identity toward cartoon soccer.

Scope:
- Replace or map collectibles, obstacles, and environmental flavor toward soccer-themed elements.
- Keep existing gameplay logic where possible.

Do not change:
- Goal-scoring mechanic yet.
- Advanced balancing.

Affected files:
- world asset mappings
- obstacle definitions
- collectible definitions
- related docs if needed

Definition of done:
- The run visually feels football-themed even before the kick mechanic is added.

Manual tests:
- Verify replaced elements are readable and collisions still work.

## CS-006
Status: pending
Title: Add kick action and random goal opportunity event

Goal:
Introduce the signature soccer interaction: kick at the right moment to score.

Scope:
- Add a kick input.
- Spawn a simple random goal opportunity event.
- Detect successful kick timing or collision with the goal window.
- Award bonus points on success.

Do not change:
- Add goalkeeper AI unless trivial.
- Add advanced soccer physics.

Affected files:
- input handling
- gameplay event system
- score system
- world spawning files

Definition of done:
- A player can trigger a kick.
- Goal opportunities appear during the run.
- Successful kicks award points.

Manual tests:
- Verify multiple goal events can occur in one run.
- Verify missed kicks do not crash the run.

## CS-007
Status: pending
Title: Add scoring layers for distance collectibles and goals

Goal:
Make scoring more arcade-like and reward soccer actions.

Scope:
- Separate score sources for run distance, pickups, and goals.
- Add a simple combo or streak for successful goals if low risk.

Do not change:
- Full economy system.
- Store or skin system.

Affected files:
- score logic
- HUD score presentation
- result screen files

Definition of done:
- Score feedback clearly reflects goals as premium scoring moments.

Manual tests:
- Verify score totals are correct across a full run.

## CS-008
Status: pending
Title: Update HUD and game over flow for Chicken Soccer

Goal:
Align the interface with the new game identity and gameplay loop.

Scope:
- Update HUD labels and icons.
- Show goals, score, and best run clearly.
- Refresh game over screen wording.

Do not change:
- Monetization.
- Leaderboards.

Affected files:
- HUD widgets
- overlays
- menu / game over UI

Definition of done:
- The interface reads as a football arcade runner, not as CKSoccer.

Manual tests:
- Verify HUD remains readable on mobile-sized screens.

## CS-009
Status: pending
Title: Add a tuning guide for Chicken Soccer core variables

Goal:
Create a markdown file explaining where key gameplay variables live and how to tune them.

Scope:
- Document movement speed, spawn rates, kick timing, goal frequency, and scoring values.

Do not change:
- Gameplay behavior unless needed to align naming.

Affected files:
- docs/chicken_soccer_tuning_guide.md

Definition of done:
- A readable tuning guide exists for future iteration.

Manual tests:
- Verify every documented variable still exists in code.

## Backlog Ideas
Status: pending
Title: Future ideas not ready for implementation

Items:
- Goalkeeper enemy
- Character skins
- Stadium themes
- Power shots
- Daily challenge
- Missions
- Rewarded ads
- Home menu polish
- Haptics and sound pass

Notes:
- Do not promote backlog ideas until CS-001 to CS-008 are stable.