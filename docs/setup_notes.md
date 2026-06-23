# Setup Notes

## CS-000: Dependency resolution fix (2026-06-22)

### Symptom

`flutter pub get` failed with:

```
Because every version of leap from git depends on tiled ^0.10.1 and every version of
flame_tiled from git depends on tiled ^0.11.0, leap from git is incompatible with
flame_tiled from git.
```

### Root cause

`pubspec.yaml` used two `dependency_overrides` that pulled incompatible git sources:

| Override     | Source                                              | `tiled` constraint |
|--------------|-----------------------------------------------------|------------------|
| `leap`       | `VeryGoodOpenSource/leap` @ `vgv`                   | `^0.10.1`        |
| `flame_tiled`| `flame-engine/flame` @ `main`                       | `^0.11.0`        |

The solver cannot satisfy both `tiled` ranges at once. The `leap` vgv fork was added for CKSoccer–specific tile-atlas behavior; overriding `flame_tiled` to Flame `main` (a much newer line) introduced the mismatch.

The original `leap` vgv `pubspec.yaml` expected a short-lived git branch (`erick.tile-atlas-padding`) for `flame_tiled`. That branch no longer exists on the Flame repo, and pinning `flame_tiled` to `main` is not a safe substitute.

### Fix applied

1. **Removed the `flame_tiled` git override** so `flame_tiled` resolves from pub.dev (`^1.15.0` → resolved `1.20.2`), which uses `tiled ^0.10.x` and aligns with `leap` vgv.
2. **Kept the `leap` git override** (`VeryGoodOpenSource/leap` @ `vgv`) for the forked platformer APIs this project uses (e.g. `TiledOptions` atlas spacing).
3. **Bumped `intl` to `^0.20.2`** — required by the current Flutter SDK’s `flutter_localizations` pin once the tiled conflict was cleared. No `dependency_overrides` were used for this.

### Why not `dependency_overrides` for `tiled`?

A `tiled` override would force one version and hope both packages work at runtime. Removing the conflicting `flame_tiled` git source is smaller and safer: pub-hosted `flame_tiled` 1.x already matches `leap` vgv’s `tiled` range without overriding transitive versions.

### Resolved versions (after fix)

- `leap`: `0.3.1` (git, `vgv`)
- `flame_tiled`: `1.20.2` (hosted)
- `tiled`: `0.10.2` (transitive, hosted)

### Verify

```bash
flutter pub get
```

### Known follow-ups (out of CS-000 scope)

- **Localization**: generated `flutter_gen` l10n files may need `flutter gen-l10n` / a full build on a clean checkout.
- **Android build**: local Gradle/Java versions may need alignment with the Flutter SDK (see `flutter doctor`).
