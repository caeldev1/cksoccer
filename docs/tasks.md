## CS-000
Status: done
Title: Fix cloned project dependency resolution and restore a runnable baseline

Goal:
Resolve package version conflicts in the cloned Super Dash project so flutter pub get and the default run flow work again.

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