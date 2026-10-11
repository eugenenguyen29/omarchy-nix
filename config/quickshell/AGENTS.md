# Quickshell — rules a run won't catch

Everything else lives in root `../../.claude/skills/vertical-slice-architecture/docs/quickshell-architecture.md-`.

## Dev shell

From the repo root:

```sh
nix develop                          # qs, qmlformat, qmlls, slurp, wf-recorder
qs -p config/quickshell/dev-bar.qml  # one slice
qs -p config/quickshell              # whole shell
nix develop -c qs -p config/quickshell/dev-bar.qml   # one-shot
```

- Needs the live Hyprland/Wayland session (`WAYLAND_DISPLAY`, `HYPRLAND_INSTANCE_SIGNATURE`).
- Agents: `nix develop` fails inside a sandbox (it locks `.gitmodules` and talks
  to the nix daemon). Run it unsandboxed.
- QML warnings go to stderr. `timeout 5 qs -p … 2>&1` is a quick smoke test.

## Seeing the result

A clean run proves nothing about layout; capture it. `wf-recorder` and `slurp`
are in the dev shell; `ffmpeg` is a system package. Never `grim` (deprecated,
not installed).

```sh
systemctl --user stop quickshell     # else the installed bar stacks above yours
qs -p config/quickshell/dev-bar.qml & sleep 4
timeout -s INT 2 wf-recorder -y -g '0,0 1533x90' -f "$TMPDIR/bar.mp4"
kill %1; systemctl --user start quickshell
ffmpeg -loglevel error -sseof -0.5 -i "$TMPDIR/bar.mp4" -frames:v 1 "$TMPDIR/bar.png"
```

- `-g` is logical pixels (`hyprctl monitors -j`; eDP-1 at scale 1.67 is 1533
  wide). `slurp` prints one if you pick by hand.
- **You MUST delete every recording, frame and probe file when done.** Never
  write them into the repo.

## Root files

Every root file (`shell.qml`, each `dev-<slice>.qml`) starts with exactly:

```qml
//@ pragma RespectSystemStyle
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Material
//@ pragma Env QT_QUICK_CONTROLS_MATERIAL_VARIANT=Dense
```

Without the block the shell runs normally but renders in Fusion. Changing a
pragma needs a restart of `qs`; saving the file is not enough.

## Imports

- Controls come from an unqualified `import QtQuick.Controls`.
- Material is imported **qualified only**: `import QtQuick.Controls.Material as M`,
  then `M.Material.…`. An unqualified import selects the style at compile time,
  so a missing pragma block would go unnoticed.
- No other style module is ever imported.

## config.json

Live reload works only against the working tree (`qs -p config/quickshell`).
The installed copy is a read-only Nix store symlink, so never edit
`~/.config/quickshell/config.json`.

## Qt Development Skills

You MUST load the matching Qt Development Skills skill before touching any
quickshell QML, and tell every subagent you hand work to that it must do the
same.

- Writing, fixing or refactoring QML: `qt-development-skills:qt-qml`.
- Designing or changing a screen, layout or control:
  `qt-development-skills:qt-ui-design`.
- Verifying a change: `qt-development-skills:qt-qml-review`.
- Chasing lag or dropped frames: `qt-development-skills:qt-qml-profiler`.

Where a skill and this file disagree, this file wins.

## Delegation

The repo-root `AGENTS.md` rule applies here. Each verifier does a smoke run
plus a capture (see *Seeing the result*).
