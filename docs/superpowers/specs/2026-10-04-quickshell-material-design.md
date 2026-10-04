# Quickshell on Qt Quick Controls Material — design

Date: 2026-10-04 · Branch: `quickshell-integration`

## Goal

Rebuild the quickshell UI on Qt Quick Controls with the Material style, keeping
the vertical-slice architecture. First, rewrite the architecture doc so slices
line up around one template and the UI rules are written down.

## Decisions

| Decision | Choice |
|---|---|
| Scope | Full Controls: every visual that has a matching Control becomes one; primitives only where none exists. |
| Style selection | Run time, via pragmas in every root file (`shell.qml`, each `dev-<slice>.qml`). |
| Theme source | Material's own palette. The Nix/Base16 plumbing is parked, not removed. |
| Variant | Dense (desktop). |
| User configuration | One hand-edited JSON file, live-reloaded. Colours and display flags only. |
| Guard against forgetting the pragmas | `config/quickshell/AGENTS.md`. |

### Why run-time selection

Quickshell forces the Fusion style unless the root file declares
`//@ pragma RespectSystemStyle`. Run-time selection keeps the style choice in a
single pragma block per root file, and the Dense variant can only be set from the
environment anyway. The cost is that every root file must repeat the block, and a
root without it silently renders in Fusion. `AGENTS.md` is there to prevent that.

### Why theme and accent are not pragmas

Pragmas are read once at startup. `Material.theme` and `Material.accent` are
attached properties, and they hot-reload like any other binding. They stay in QML:
`Theme` holds the choices and `Surface` applies them.

## Deliverables

### 1. `config/quickshell/AGENTS.md` (new)

Short. Holds only the rules a run of the shell would not catch:

- Every root file starts with exactly:
  ```qml
  //@ pragma RespectSystemStyle
  //@ pragma Env QT_QUICK_CONTROLS_STYLE=Material
  //@ pragma Env QT_QUICK_CONTROLS_MATERIAL_VARIANT=Dense
  ```
  Without the block the shell runs normally but renders in Fusion. Changing a
  pragma needs a restart of `qs`; saving the file is not enough.
- Controls come from an unqualified `import QtQuick.Controls`. The Material
  module is imported **qualified only** (`import QtQuick.Controls.Material as M`,
  then `M.Material.…`). Its qmldir exports every Material control, so an
  unqualified import would select the style at compile time behind the pragmas'
  back, and a missing pragma block would go unnoticed. No other style module is
  ever imported.
- Live reload of `config.json` works only against the working tree
  (`qs -p config/quickshell`). The installed copy is a read-only Nix store
  symlink, so never edit `~/.config/quickshell/config.json`.
- Everything else lives in `docs/quickshell-architecture.md`.

### 2. `docs/quickshell-architecture.md` rewrite

General guidelines only, with no implementation details.

1. **UI section (new).** Controls first; primitives only where no Control fits
   (custom `Shape` outlines, indicator dots, non-interactive pills). Each window
   has one `Surface` as its root item, the only place the Material theme, accent
   and font are set; slices never set them. Per-control attributes (`elevation`,
   `roundedScale`) are fine. Sizes and motion still come from `shared/theme/`.
   Every control placed in a fixed-height strip has its height set explicitly
   from a size token, because Material's default heights are taller than a bar.
2. **Slice template.** The scattered slice rules become one template: a tree
   plus an ordered checklist (directory → entry point → `<Slice>State` → bases →
   `internal/` → `dev-<slice>.qml` with the pragma block and the same config
   mapping as `shell.qml` → one line in `shell.qml`).
3. **Configuration rule.** User configuration is one declarative JSON file
   loaded by one kernel singleton. `shell.qml` and the harnesses map it onto flat
   entry-point properties; a slice never reads a file. Colours are shell-wide.
   Deeper configuration is added only when it is needed. `shared/config/` joins
   the kernel layout.
4. **Feature-specific rules leave the doc.** The "Privacy indicators" section
   moves into the header comment of `PrivacyItem.qml`. The doc states the
   general rule: a feature's own conventions live with the feature, in its base
   component's header.
5. **`shared/ui` defined.** Themed wrappers around Controls that take content and
   emit signals. A wrapper is added once two slices need the same styling. The
   first one is `Surface`.
6. **The project principle is restated.** The user-facing JSON file owns
   configuration, QML owns behaviour and layout, and Nix only builds and
   installs. The Nix palette is parked; plumbing it back in later only changes
   `Theme`.
7. Override #2 ("Primitives over Qt Quick Controls") is removed and replaced by
   item 1.
8. **Review checklist updates.**
   - Add: the pragma block is present in every root file.
   - Add: the Material module is imported qualified only.
   - Add: no slice sets `Material.theme`, `accent` or `font`.
   - Add: bar-strip controls have an explicit height.
   - Replace "Slices import `Theme`, never `Base16`" with "colours come from
     `Theme` or the Material attached colours, never literals".
   - Replace the `palette.json` fallback check with: the harness runs with no
     `config.json` and shows the defaults.

### 3. Theme kernel

- `Theme.qml` holds Material *choices*:
  - the theme, dark or light, from config;
  - the accent, from config, given as the name of a Material predefined colour.
    It is mapped through `Material[name]`, and an unknown name falls back to the
    default accent. A JSON string must never be passed straight to
    `Material.accent`: it would parse as a CSS colour (`"Teal"` is `#008080`,
    not Material Teal).
  - fixed status colours: success = Green, warn = Amber, error = Red, at the
    shade Material uses for the active theme (200 when dark, 500 when light).
- `Base16.qml` is deleted. Nothing reads `~/.config/omarchy/palette.json` any more.
  `modules/home-manager/quickshell.nix` still writes it, unchanged, so it is
  ready for the later theme plumbing.
- `Config`, `Motion` and `Typography` stay.

### 4. `shared/ui/Surface.qml` (new)

A `Pane` that is the root item of a window. It has `padding: 0` and a
transparent background, so it paints nothing itself. It sets `Material.theme`,
`Material.accent`, `font.family` and `font.pixelSize` (`Typography.body`) from
the theme kernel. Everything visible in the window is its child, so the theme
reaches all of it.

### 5. Declarative configuration, kept shallow

User configuration is a single JSON file, `config/quickshell/config.json`,
which is committed and edited by hand. For now it covers only **colours** and
**display flags**. Section placement, ordering and per-item layout are out of
scope until they are needed.

```json
{
  "theme": { "dark": true, "accent": "Teal" },
  "bar": {
    "showWorkspaces": true, "showDate": true, "showClock": true,
    "showAudio": true, "showCamera": true, "showMicrophone": true,
    "privacyAlwaysShown": true
  }
}
```

- **Loader:** `shared/config/ShellConfig.qml`, a `pragma Singleton` holding a
  `FileView` with a `JsonAdapter`.
  - `path: Quickshell.shellDir + "/config.json"` (`shellDir` is the folder
    holding the root file, for `shell.qml` and every `dev-<slice>.qml` alike).
  - `blockLoading: true`, so the first frame uses the file's values.
  - `watchChanges` plus a reload on `fileChanged`, for the live reload.
  - The shell only reads the file and never writes it back.
- **Fallback, as probed on Quickshell 0.3.1:** the adapter's defaults apply
  when the shell starts with the key missing or the file absent. While the
  shell is running, a saved edit updates its keys live. A **removed** key, a
  **broken** file or a **deleted** file keeps the last good values, with a
  warning logged, until the next restart. This is accepted. Resetting on every
  load is not worth the code for a hand-edited file.
- **Colours:** shell-wide; `Theme` reads `ShellConfig.theme` (deliverable 3).
- **Display flags:** flat, one object per slice. `shell.qml`, and the slice's
  `dev-<slice>.qml`, bind them onto the entry point's flat `bool` properties.
  Every flag defaults to `true`.
- The two placeholder items (CPU, memory) get no flags. They will be replaced
  by their real slices.
- The name `ShellConfig`, not `Settings`, because `Settings` is already a
  QtQuick type.

### 6. Bar slice

**Window tree.** Each bar window is laid out like this:

```
PanelWindow (transparent)
└─ Surface (fills the window; padding 0, no background; theme root)
   ├─ strip  — the 32 px bar, paints the bar colour; holds the three sections
   └─ Popout — under the strip
```

The input mask stays `strip` + `Popout`, never `Surface`, so the area below the
bar still passes clicks through to the desktop.

**Mapping.**

| Today | Becomes | Note |
|---|---|---|
| Bar strip `Rectangle` | `Pane` (`padding: 0`) | Paints `Material.background` as the bar colour. |
| `BarItem` (Row + HoverHandler + Texts) | `ToolButton` with a custom `contentItem` | The `contentItem` is a `Row`: glyph `Label`, text `Label` (`Typography.medium`), and `StatusDot` anchored to the glyph as today. The `color` property stays; muted text uses `Material.hintTextColor`. `hovered` drives the popout claim, keeping the "only release your own claim" guard; `onClicked` replaces per-item `TapHandler`s. Height is `implicitHeight: Config.barHeight` (insets only shape the ripple). |
| `BarGroup` plate | `Frame` | Outlined; `padding` from `Config`. A `Pane` would be the same colour as the bar. |
| `PrivacyItem` pill | **stays a primitive** (`Rectangle` + `Label`) | A non-clickable status pill has no matching Control. A `Button` brings ripples, press elevation, an idle fill and a too-tall default size, and its `highlighted` colour is the accent rather than success green. Colours come from `Theme`'s status colours. The tracking contract (`inUse`, `available`) is unchanged. |
| `Popout` | `Pane` with the fillet `Shape` as `background` | The `background` has `implicitWidth: 0` and `implicitHeight: 0`, so the panel's size never feeds back into itself (the current file's binding-loop note still applies). Horizontal padding is `wing + Config.spacingLarge`, vertical padding is `Config.spacing`. The clip-and-fade item becomes the `contentItem`, forwarding the `Loader`'s implicit size. `Pane.hovered` replaces the `HoverHandler`. Hover-held open and the slide/resize between items are unchanged. A `Popup` was rejected: it opens and closes as a unit, so the morph would be lost. |
| Popout content `Text` | `Label` | Explicit `Typography.title` size. |
| Workspace dots | `AbstractButton` per dot, the dot as `background` | `implicitWidth` and `implicitHeight` come from the background's implicit size (the bare template has none). The width `Behavior` moves to the background. Gives pressed and hovered states and `onClicked`. |
| `StatusDot` | primitive (unchanged shape) | Colours from `Theme`'s status colours and `Material.accent`. |
| `BarSection` | `Row` (unchanged) | Layout only. |
| CPU and memory placeholders | `BarItem` (so `ToolButton`) | They show a hover ripple until their slices land. Accepted. |

Behaviour that must not change: the popout ownership/hover handoff, the popout
open/close motion and fillet drain, the workspace ordering and per-monitor
marking, the privacy visibility config, the `barToggle` shortcut, and the
input mask.

## Verification

There is no lint gate (see the architecture doc), so verification is running the
shell:

1. `qs -p config/quickshell/dev-bar.qml` renders in Material: ToolButton
   ripples, the outlined group, the accent workspace pill. The popout's labels
   use the dark theme and the shell font.
2. Remove the pragma block from the harness, then restart: the bar renders in
   Fusion. Restore the block. This confirms the pragmas select the style, which
   is what `AGENTS.md` protects. It only holds because of the qualified-import
   rule.
3. Each preserved behaviour above, checked by hand: hover between items (the
   popout slides rather than reopening), clicking a workspace, muting audio,
   lighting the mic/camera pills (e.g. `arecord`), SUPER+SHIFT+SPACE, and
   clicking the desktop just below the bar (it must reach the desktop).
4. With the harness running, set each `show*` flag to `false` in `config.json`
   and save: the item disappears and the section closes up around it, with no
   restart. Change `accent` to another Material name: the accent updates live.
   Set it to an unknown name: the default accent is used. Move `config.json`
   away and restart: the defaults are shown.
5. `qs -p config/quickshell` (the whole shell) starts with no QML warnings.

## Out of scope

- Plumbing the Nix/Base16 palette into Material (a later step).
- New slices (powermenu, osd, …) and new controls such as a volume slider.
- Section placement, ordering or layout configuration.
- Resetting removed config keys to their defaults without a restart.
