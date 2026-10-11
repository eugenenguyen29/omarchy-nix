# Quickshell — How to work in this tree

Quickshell 0.3.1 · Qt 6.11 · QML (Qt 6 dialect, no import versions)
Code: `config/quickshell/` · Nix: `modules/home-manager/quickshell.nix`

One QML process owns every desktop surface, replacing waybar / wofi / mako /
hyprlock one slice at a time. The structure is **vertical slices by feature plus
one shared kernel** — no technical-layer folders.

Rules a run of the shell would not catch (the style pragmas, the qualified
Material import, where `config.json` may be edited) live in
`config/quickshell/AGENTS.md`. Read it first.

## Skills own the generic rules

Do not look for them here. `vertical-slice-architecture` owns slice shape and
the promote-on-third-use rule; `qt-qml` owns QML coding rules; `qt-ui-design`
owns the type scale and colour-token naming. Qt API facts: verify against the
`qt-docs` MCP server, never from memory.

Two `qt-qml` rules are overridden here:

1. **`pragma Singleton` needs no `qmldir` entry.** Quickshell synthesizes module
   registration at runtime. There are no `qmldir` files in this tree and none
   should be added — a directory that has one stops getting the synthesis, so
   any type missing from the file stops existing at runtime.
2. **No `qsTr()`.** Single-user shell; i18n is out of scope.

## The one project principle

**The user's JSON file owns configuration, QML owns behaviour and layout, Nix
only builds and installs.** No QML file hardcodes a colour, a font name, or a
pixel constant — sizes and motion come from `shared/theme/`, colours from the
Material style. Every QML file is committed, so the tree runs from a fresh
clone.

The Nix palette is parked: Nix still writes it, nothing reads it. Plumbing it
back in later changes only `Theme`.

## UI

- **Controls first.** Every visual that has a matching Qt Quick Control is that
  Control, in the Material style. Primitives only where no Control fits: custom
  `Shape` outlines, indicator dots, non-interactive pills.
- **One `Surface` per window, as its root item.** It is the only place the
  Material theme, accent and font are set. Slices never set them; per-control
  attributes (`elevation`, `roundedScale`) are fine.
- **Sizes and motion still come from `shared/theme/`.** Material supplies
  colours and control behaviour, not the shell's spacing grid or timing.
- **Fixed-height strips set control heights explicitly**, from a size token.
  Material's default heights are taller than a bar.

## Layout

```
config/quickshell/
  AGENTS.md                 # the rules a run won't catch — read first
  config.json               # the user's configuration, hand-edited
  shell.qml                 # composition root — the ONLY file importing qs.features.*
  dev-<slice>.qml           # per-slice harness; MUST sit at this root, not in the slice
  features/<slice>/
    <Slice>.qml             # entry point, PascalCase of the directory
    <Slice>State.qml        # pragma Singleton — slice-private state
    <Base>.qml              # base components: shared behaviour and shape
    internal/               # concrete components built on the bases
  shared/                   # the kernel
    config/                 # the one singleton that loads config.json
    theme/                  # sizes, motion, typography, Material choices
    ui/                     # themed wrappers around Controls
    services/<x>/           # ONLY where there is real logic — see below
```

Only two folder kinds: `features/` and `shared/`. No `components/`, `widgets/`,
`models/`.

Naming, the same rule at both levels: a directory whose name matches one of its
files is a unit. Directory `lower-kebab`, entry point `PascalCase` of it,
helpers prefixed with the unit name when the bare name would be generic
(`AudioSink.qml`, `NetIcon.qml`). Helpers live inside their unit's folder, never
in a catch-all `util/`.

## Slice template

```
features/<slice>/
  <Slice>.qml        # entry point; flat properties in, nothing else public
  <Slice>State.qml   # only if state must survive reload
  <Base>.qml         # bases: behaviour and shape
  internal/          # concrete components built on the bases
dev-<slice>.qml      # at the config root
```

In order:

1. **Directory** `features/<slice>/`, `lower-kebab`.
2. **Entry point** `<Slice>.qml`, named after the directory. It is the slice's
   only public surface. Configuration arrives as flat properties on it.
   Everything else in the folder is private by convention — review enforces it,
   QML cannot.
3. **`<Slice>State.qml`**, only for state that must survive hot reload.
   Singletons keep their property values across a reload; window and delegate
   properties are rebuilt from bindings. Anything the user would hate to lose
   mid-edit (open state, query text, expanded item) belongs in the singleton;
   derived values belong in bindings.
4. **Bases** at the top of the slice folder. A component that defines behaviour
   and shape for others to build on (a generic item, container or popup) is a
   base. Its header comment holds the feature's own conventions.
5. **`internal/`** for concrete components that fill a base in with specific
   data or logic. They import the slice (`import qs.features.<slice>`) to get
   their bases. Bases never import `internal/`; if a base would need something
   from there, that thing is a base too, so move it up.
6. **`dev-<slice>.qml`** at the config root, starting with the pragma block from
   `AGENTS.md`, mapping configuration onto the entry point exactly as
   `shell.qml` does.
7. **One line in `shell.qml`.** Reading `shell.qml` must tell you every feature
   the shell has and nothing else.

Rules that hold for every slice:

- **Use Quickshell's `Singleton` as the root, not `QtObject`** — only the former
  joins the reload graph.
- **Every file imports `QtQuick` explicitly.** `import Quickshell` alone gives no
  value types, and `property color` then fails with `color is not a type`.
- **Popups never get a second `PanelWindow`.** Grow them inside the owning
  window (masked so the empty area passes clicks through) or use a
  `PopupWindow` anchored to an item. A hand-placed second panel takes exclusion
  zones and breaks on multi-monitor.
- **Keybindings use `GlobalShortcut`**, declared in the slice and bound in
  `hyprland/bindings.nix` as `global, quickshell:<name>`. `IpcHandler` is for
  scripts and debugging only — a `qs ipc call` spawns a process per keypress.
  Pair menus with `HyprlandFocusGrab` so click-outside dismisses.
- **A feature's own conventions live with the feature**, in its base
  component's header — not in this doc.

## Configuration

- **One declarative JSON file, loaded by one kernel singleton.** The user edits
  it by hand; the shell only reads it.
- **Roots map it, slices never read it.** `shell.qml` and each harness bind it
  onto the entry point's flat properties. A slice never reads a file or an env
  var itself.
- **Colours are shell-wide**, read by `Theme`. Everything else is per slice.
- **Defaults live in the loader**, so the shell runs with no file at all.
- **Shallow until needed.** Deeper configuration (placement, ordering, layout)
  is added when something needs it, not before.

## Shared kernel rules

- `shared/` never imports `qs.features.*` — circular, instant reject.
- **Wrap a service only to add semantics.** `Pipewire`, `UPower`, `SystemTray`,
  `Networking`, `Mpris`, `Hyprland` are already process-wide singletons; import
  them directly. Write `shared/services/<x>/` only for real logic: default-sink
  resolution, `PwObjectTracker` lifetime, picking the display battery out of
  `UPower.devices`, primary-device selection.
- A helper wanted by two concerns gets promoted to its own unit — and the copies
  are deleted in the same commit.
- **`shared/ui/` holds themed wrappers around Controls.** They take content and
  emit signals: no service access, no IPC, no process spawning. A wrapper is
  added once two slices need the same styling.
- **Colours come from `Theme` or the Material attached colours**, never
  literals.
- **Check new shared singleton names against QtQuick's types.** `Palette`,
  `Screen`, `Settings` and `Action` are taken; a collision resolves to the
  QtQuick type and reports every token as a missing property while the shell
  runs fine.

## Imports

Always `import qs.shared.theme` — never relative `../../shared/theme`.

Resolution is **per directory, not per unit**: siblings need no import
(`<Slice>.qml` sees `<Slice>State.qml` for free), but `internal/` is a different
module, so the entry point needs `import qs.features.<slice>.internal`. A slice importing its own
`internal/` is fine; the ban is on importing *other* slices.

## Workflow

```
nix develop
qs -p config/quickshell               # the whole shell, against the working tree
qs -p config/quickshell/dev-bar.qml   # one slice
qmlformat -i config/quickshell/**/*.qml
```

Saving reloads the running shell — leave one `qs` running while you work.

The installed shell is the `quickshell` systemd user service
(`modules/home-manager/quickshell.nix`), started with `hyprland-session.target`
and restarted on crash. It runs the copy in `~/.config/quickshell`, which only
changes on `home-manager switch` — so stop it while working against the tree:

```
systemctl --user stop quickshell      # before qs -p config/quickshell
systemctl --user start quickshell     # back to the installed copy
```

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
| 1 | `features/bar` | waybar | Port modules one at a time. |
| 2 | `features/powermenu` | wofi + `scripts/omarchy-power-menu.sh` | |
| 3 | `features/osd` | — | |
| 4 | `features/notifications` | mako | |
| 5 | `features/launcher` | walker/wofi | Optional; walker is competitive. |
| 6 | `features/lock` | hyprlock | Highest risk — keep hyprlock installed and a TTY reachable. |

## Review checklist

- [ ] Every root file (`shell.qml`, each `dev-<slice>.qml`) starts with the
      pragma block from `AGENTS.md`.
- [ ] The Material module is imported qualified only; no other style module.
- [ ] No slice sets `Material.theme`, `accent` or `font` — only `Surface` does.
- [ ] Controls in a fixed-height strip have an explicit height.
- [ ] No `import qs.features.*` outside `shell.qml`, `shared/` included —
      except a slice's `internal/` importing its own slice for its bases.
- [ ] Bases at the slice top level, concrete components in `internal/`; no
      base imports `internal/`.
- [ ] Module imports (`qs.*`), never relative paths.
- [ ] No `qmldir` file anywhere in the tree.
- [ ] Slice config arrives as properties; no slice reads a file or env var.
- [ ] Colours come from `Theme` or the Material attached colours, never
      literals; no font name or pixel constant outside `shared/theme/`.
- [ ] Every `.qml` committed; Nix generates data, not QML.
- [ ] New `shared/services/` wrapper adds semantics, isn't a pass-through.
- [ ] Quickshell `Singleton` root; `QtQuick` imported in every file.
- [ ] New shared singleton name doesn't collide with a QtQuick type.
- [ ] Reload-surviving state is in a singleton, not on a window.
- [ ] No second `PanelWindow` for a popup; keybindings are `GlobalShortcut`.
- [ ] The slice's `dev-<slice>.qml` runs with **no** `config.json` and shows the
      defaults — only `FileView`'s own "File does not exist" notice.
