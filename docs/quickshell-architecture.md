# Quickshell — How to work in this tree

Quickshell 0.3.1 · Qt 6.11 · QML (Qt 6 dialect, no import versions)
Code: `config/quickshell/` · Nix: `modules/home-manager/quickshell.nix`

One QML process owns every desktop surface, replacing waybar / wofi / mako /
hyprlock one slice at a time. The structure is **vertical slices by feature plus
one shared kernel** — no technical-layer folders.

## Skills own the generic rules

Do not look for them here. `vertical-slice-architecture` owns slice shape and
the promote-on-third-use rule; `qt-qml` owns QML coding rules; `qt-ui-design`
owns the type scale and colour-token naming. Qt API facts: verify against the
`qt-docs` MCP server, never from memory.

Three `qt-qml` rules are overridden here:

1. **`pragma Singleton` needs no `qmldir` entry.** Quickshell synthesizes module
   registration at runtime. There are no `qmldir` files in this tree and none
   should be added — a directory that has one stops getting the synthesis, so
   any type missing from the file stops existing at runtime.
2. **Primitives over Qt Quick Controls.** Build from `QtQuick` + `shared/ui/`.
   Reach for Controls only when a real control's behaviour (text editing, scroll
   physics) is worth overriding its style.
3. **No `qsTr()`.** Single-user shell; i18n is out of scope.

## The one project principle

**Nix owns configuration and theming; QML owns behaviour and layout.** No QML
file hardcodes a colour, a font name, or a pixel constant — those come from
`shared/theme/`. Nix generates *data* (`~/.config/omarchy/palette.json`), never
`.qml`: every QML file is committed, so the tree runs from a fresh clone.

## Layout

```
config/quickshell/
  shell.qml                 # composition root — the ONLY file importing qs.features.*
  dev-<slice>.qml           # per-slice harness; MUST sit at this root, not in the slice
  features/<slice>/
    <Slice>.qml             # entry point, PascalCase of the directory
    <Slice>State.qml        # pragma Singleton — slice-private state
    internal/               # sub-components, appears once there are two of them
  shared/                   # the kernel
    theme/                  # Theme (semantic tokens), Base16, Typography, Metrics
    ui/                     # themed dumb components, flat until one grows helpers
    services/<x>/           # ONLY where there is real logic — see below
    util/<x>/
```

Only two folder kinds: `features/` and `shared/`. No `components/`, `widgets/`,
`models/`.

Naming, the same rule at both levels: a directory whose name matches one of its
files is a unit. Directory `lower-kebab`, entry point `PascalCase` of it,
helpers prefixed with the unit name when the bare name would be generic
(`AudioSink.qml`, `NetIcon.qml`). Helpers live inside their unit's folder, never
in a catch-all `util/`.

## Writing a slice

- **One entry point**, named after the directory. It is the slice's only public
  surface. Everything else in the folder is private by convention — review
  enforces it, QML cannot.
- **Configuration arrives as properties** set by `shell.qml`. A slice never
  reads a file or an env var itself.
- **State that must survive hot reload goes in `<Slice>State.qml`.** Singletons
  keep their property values across a reload; window and delegate properties are
  rebuilt from bindings. Anything the user would hate to lose mid-edit (open
  state, query text, expanded item) belongs in the singleton; derived values
  belong in bindings.
- **Use Quickshell's `Singleton` as the root, not `QtObject`** — only the former
  joins the reload graph.
- **Every file imports `QtQuick` explicitly.** `import Quickshell` alone gives no
  value types, and `property color` then fails with `color is not a type`.
- **Popups are `PopupWindow` anchored to an item**, never a second
  `PanelWindow`. A hand-placed second panel takes exclusion zones and breaks on
  multi-monitor.
- **Keybindings use `GlobalShortcut`**, declared in the slice:
  `bind = SUPER, Escape, global, quickshell:powermenuToggle` in
  `hyprland/bindings.nix`. `IpcHandler` is for scripts and debugging only — a
  `qs ipc call` spawns a process per keypress. Pair menus with
  `HyprlandFocusGrab` so click-outside dismisses.

Adding a feature: create the directory, add one line to `shell.qml`. Reading
`shell.qml` must tell you every feature the shell has and nothing else.

## Shared kernel rules

- `shared/` never imports `qs.features.*` — circular, instant reject.
- **Wrap a service only to add semantics.** `Pipewire`, `UPower`, `SystemTray`,
  `Networking`, `Mpris`, `Hyprland` are already process-wide singletons; import
  them directly. Write `shared/services/<x>/` only for real logic: default-sink
  resolution, `PwObjectTracker` lifetime, picking the display battery out of
  `UPower.devices`, primary-device selection.
- A helper wanted by two concerns gets promoted to its own unit — and the copies
  are deleted in the same commit.
- `shared/ui/` components take content and emit signals. No service access, no
  IPC, no process spawning.
- Slices import `Theme`, never `Base16`. That keeps a theme change one file and
  stops `base0D` leaking into thirty call sites.
- **Check new shared singleton names against QtQuick's types.** `Palette`,
  `Screen`, `Settings` and `Action` are taken; a collision resolves to the
  QtQuick type and reports every token as a missing property while the shell
  runs fine.

## Imports

Always `import qs.shared.theme` — never relative `../../shared/theme`.

Resolution is **per directory, not per unit**: siblings need no import
(`Bar.qml` sees `BarState.qml` for free), but `internal/` is a different module,
so `Bar.qml` needs `import qs.features.bar.internal`. A slice importing its own
`internal/` is fine; the ban is on importing *other* slices.

## Workflow

```
nix develop
qs -p config/quickshell               # the whole shell, against the working tree
qs -p config/quickshell/dev-bar.qml   # one slice
qmlformat -i config/quickshell/**/*.qml
```

Saving reloads the running shell — leave one `qs` running while you work.

There is no lint gate. `qmllint` cannot resolve `qs.*` imports without per-
directory `qmldir` files, and those break quickshell's runtime synthesis; the
scaffolding that reconciled the two cost more than it caught. Same for `qmlls`
completion across `qs.*` imports. Correctness comes from running the shell.

**Every slice must run standalone** via its `dev-<slice>.qml`. The harness has
to live at the config root: `-p <file>` rebases the `qs` module root onto that
file's directory, so `qs -p features/bar/Bar.qml` fails with
`module "qs.shared.theme" is not installed`. A slice that cannot get a harness
has leaked a dependency into the composition root.

## Migration order

waybar/wofi keep running until their replacement merges; each step ships alone.

| # | Slice | Replaces | Notes |
|---|---|---|---|
| 1 | `shared/theme` + `shell.qml` + clock-only `Bar` | — | **Done.** No `exec-once` yet; waybar still runs. |
| 2 | `features/bar` | waybar | Largest. Port modules one at a time. |
| 3 | `features/powermenu` | wofi + `scripts/omarchy-power-menu.sh` | First `GlobalShortcut` slice. |
| 4 | `features/osd` | — | **Brightness has no quickshell service** — needs `Process`/`brightnessctl`. Not a small slice. |
| 5 | `features/notifications` | mako | `NotificationServer` + persistence. |
| 6 | `features/launcher` | walker/wofi | Optional; walker is competitive. |
| 7 | `features/lock` | hyprlock | `WlSessionLock` + `PamContext`. Highest risk — keep hyprlock installed and a TTY reachable. |

## Review checklist

- [ ] No `import qs.features.*` outside `shell.qml`, `shared/` included.
- [ ] Module imports (`qs.*`), never relative paths.
- [ ] No `qmldir` file anywhere in the tree.
- [ ] Slice config arrives as properties; no slice reads a file or env var.
- [ ] No hex colour, font name or pixel constant outside `shared/theme/`.
- [ ] Every `.qml` committed; Nix generated data, not QML.
- [ ] New `shared/services/` wrapper adds semantics, isn't a pass-through.
- [ ] Quickshell `Singleton` root; `QtQuick` imported in every file.
- [ ] New shared singleton name doesn't collide with a QtQuick type.
- [ ] Reload-surviving state is in a singleton, not on a window.
- [ ] Popups are `PopupWindow`; keybindings are `GlobalShortcut`.
- [ ] The slice's `dev-<slice>.qml` runs against a tree with **no**
      `~/.config/omarchy/palette.json` — fallback palette, only `FileView`'s own
      "File does not exist" notice.
