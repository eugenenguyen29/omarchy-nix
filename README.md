# Omarchy Nix

This is a personal fork of [henrysipp/omarchy-nix](https://github.com/henrysipp/omarchy-nix), a NixOS flake that reimplements [DHH's Omarchy](https://github.com/basecamp/omarchy), an opinionated Hyprland setup, as NixOS and home-manager modules.

The fork tracks one machine. It follows `nixos-unstable`, pins Hyprland to `v0.56.0`, and is hardware-specific in places: among other things, the NixOS module turns on the T2 Mac audio DSP for a MacBookPro15,4 unconditionally (see [Hardware assumptions](#hardware-assumptions)). Treat it as a reference or a starting point for your own config, not as a general-purpose distribution.

## Direction

I am moving the desktop surfaces into a single [Quickshell](https://quickshell.org/) process written in QML, one slice at a time. The planned slices are the bar (replacing waybar), the power menu (replacing wofi), notifications (replacing mako) and the lock screen (replacing hyprlock). An on-screen display is planned as a new surface; nothing provides one today. Replacing the walker launcher is optional. The rule for the work is that the user's JSON file owns configuration, QML owns behaviour and layout, and Nix only builds and installs.

Where it stands in this tree:

- The bar is the first slice and the only one so far. It runs from Quickshell, and the waybar module is no longer imported. It shows workspaces, date, clock, audio, network, power profile, CPU, memory, and camera and microphone indicators, and opens a control centre popout with Wi-Fi and Bluetooth toggles and volume and brightness sliders. It has no battery or system tray item yet.
- The power menu still runs through wofi (`omarchy-power-menu`), notifications through mako, the launcher through walker, and the lock screen through hyprlock.

The shell runs as a systemd user service started with `hyprland-session.target`, uses Qt Quick Controls in the Material style, and reads its settings from [`config/quickshell/config.json`](config/quickshell/config.json). The structure, the rules and the migration order are in [`docs/quickshell-architecture.md`](docs/quickshell-architecture.md).

## What the fork adds

New in the fork:

- `modules/home-manager/quickshell.nix`, `config/quickshell/` and `shells/qt.nix`: the Quickshell shell described above and its dev shell.
- `modules/home-manager/lid/`: turns the internal panel off while the lid is closed and an external monitor is connected (`omarchy.lid.*`).
- `modules/home-manager/hyprland/hyprmod.nix`: installs [HyprMod](https://github.com/BlueManCZ/hyprmod), a GUI settings app for Hyprland. It writes `~/.config/hypr/hyprland-gui.conf`, which is sourced last in `hyprland.conf` so its settings take precedence over the ones declared in Nix.
- `modules/home-manager/walker.nix`: the walker launcher, bound to `SUPER + space`.
- `modules/nixos/t2-dsp.nix`: speaker and microphone DSP for T2 Macs.
- `scripts/omarchy-power-menu.sh`: a wofi power menu on `SUPER + SHIFT + Q`.
- The `desktop_wallpaper` and `hyprlock_wallpaper` options.

Changed from upstream:

- 1Password (`modules/nixos/1password.nix`) is upstream's; the fork added gnome-keyring so the sign-in survives a reboot.
- The greetd and tuigreet login is upstream's; the fork moved it to `modules/nixos/greeter.nix` and gave it a dedicated `greeter` user.
- Hyprland is pinned to `v0.56.0`; the reason is in the comment in [`flake.nix`](flake.nix).

## Quick start

Start from a working [NixOS](https://nixos.org/) install. Add the two modules to the module list of your existing system flake, alongside your own hardware and host configuration. This README describes the tree it is committed with, on the `quickshell-integration` branch, so the flake URL names that branch.

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    omarchy-nix = {
      url = "github:eugenenguyen29/omarchy-nix/quickshell-integration";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, omarchy-nix, home-manager, ... }: {
    nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix # your own host and hardware configuration
        omarchy-nix.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          omarchy = {
            full_name = "Your Name";
            email_address = "your.email@example.com";
            theme = "tokyo-night";
          };

          home-manager = {
            useGlobalPkgs = true;
            users.your-username = {
              imports = [ omarchy-nix.homeManagerModules.default ];
              home.stateVersion = "25.05"; # the release you first installed home-manager on
            };
          };
        }
      ];
    };
  };
}
```

`useGlobalPkgs` is there because the flake sets `nixpkgs.config.allowUnfree = true` on the NixOS side only, while the home-manager module enables VS Code, which is unfree.

### What the NixOS module changes

Importing `nixosModules.default` applies all of this, with no option to turn parts off:

- greetd with tuigreet takes over login (`modules/nixos/greeter.nix`).
- Docker is enabled (`modules/nixos/containers.nix`).
- 1Password CLI and GUI are installed, with gnome-keyring (`modules/nixos/1password.nix`).
- PipeWire replaces PulseAudio; NetworkManager, bluetooth and systemd-resolved are enabled (`modules/nixos/system.nix`).
- `tuned` handles power profiles and power-profiles-daemon is turned off (`modules/nixos/system.nix`).
- Hyprland is enabled system-wide (`modules/nixos/hyprland.nix`).
- The fonts the bar needs, `material-symbols` and `nerd-fonts.caskaydia-mono`, are installed here and nowhere else, so the home-manager module alone leaves the bar without them.

### Hardware assumptions

These are applied unconditionally and assume the machine the fork runs on:

- T2 audio DSP with `model = "15_4"`, a MacBookPro15,4 (`modules/nixos/default.nix`).
- `AQ_NO_MODIFIERS,1`, a workaround for Intel gen9 graphics (`modules/home-manager/hyprland/envs.nix`).
- The backlight device is hardcoded as `acpi_video0` (`modules/home-manager/hyprland/bindings.nix`, `modules/home-manager/hypridle.nix`, `config/quickshell/features/bar/internal/ControlCenter.qml`).
- `SUPER + SHIFT + P` runs `disable-apple-trackpad`, which targets the Apple internal trackpad (`modules/home-manager/hyprland/bindings.nix`).
- hyprlock has fingerprint authentication enabled (`modules/home-manager/hyprlock.nix`).
- btop is wrapped with `cap_perfmon` to read Intel GPU usage from the i915 PMU (`modules/nixos/system.nix`).

The DSP can be turned off from your own configuration; the others need an edit or an override of the Hyprland settings.

```nix
{ lib, ... }:
{
  t2AppleAudioDSP.enable = lib.mkForce false;
}
```

## Configuration options

All `omarchy.*` options are declared in [`config.nix`](config.nix). Options set on the NixOS side are passed through to the home-manager module.

### Themes

The predefined themes are:

- `tokyo-night` (default)
- `kanagawa`
- `everforest`
- `nord`
- `gruvbox`
- `gruvbox-light`

The option type also accepts `catppuccin`, but that name does not resolve to a theme, so do not use it.

A theme can also be generated from a wallpaper image:

- `generated_light` generates a light color scheme from the wallpaper
- `generated_dark` generates a dark color scheme from the wallpaper

Generated themes require a wallpaper path:

```nix
{
  omarchy = {
    theme = "generated_dark"; # or "generated_light"
    theme_overrides = {
      wallpaper_path = ./path/to/your/wallpaper.png;
    };
  };
}
```

The theme sets the color scheme for Ghostty, btop, Hyprland, hyprlock, mako and wofi. The Quickshell bar does not follow it yet; its colors come from `config.json` (see [Quickshell](#quickshell)).

#### Wallpaper overrides

Setting `theme_overrides.wallpaper_path` with a predefined theme changes only the wallpaper and keeps the theme's color scheme:

```nix
{
  omarchy = {
    theme = "tokyo-night";
    theme_overrides = {
      wallpaper_path = ./path/to/your/wallpaper.png;
    };
  };
}
```

#### Desktop and lock screen wallpapers

The desktop (hyprpaper) and lock screen (hyprlock) wallpapers can be chosen independently:

```nix
{
  omarchy = {
    theme = "tokyo-night";
    desktop_wallpaper = ./path/to/desktop.jpg;
    hyprlock_wallpaper = ./path/to/lockscreen.jpg;
  };
}
```

Both are optional and fall back in this order:

- `desktop_wallpaper` → `theme_overrides.wallpaper_path` → the wallpaper shipped with the selected theme
- `hyprlock_wallpaper` → whatever the desktop wallpaper resolved to

Custom images are linked into `~/Pictures/Wallpapers` by home-manager (prefixed `desktop-` / `lock-`), since hyprpaper and hyprlock both require absolute paths.

### Displays and lid

```nix
{
  omarchy = {
    monitors = [ "eDP-1, preferred, auto, 2" ];
    scale = 2;
    lid = {
      enable = true;
      internal_monitor = "eDP-1";
      exclusive_monitors = [ "BNQ BenQ GW2480" ];
    };
  };
}
```

- `monitors` is a list of Hyprland `monitor` rules. Default: empty. HyprMod's `hyprland-gui.conf` is sourced after them, so a rule saved from the GUI for the same output wins.
- `scale` is an integer exported as `GDK_SCALE`. Default: `2`. The lid handler also uses it as the internal panel's scale when it finds no monitor rule for it.
- `lid.enable` turns the internal panel off when the lid closes while another monitor is connected, and back on when it opens. Default: off.
- `lid.backend` selects the implementation. `"hyprland"` is the only one.
- `lid.internal_monitor` is the output name of the built-in panel. Default: `"eDP-1"`.
- `lid.exclusive_monitors` lists external outputs that cannot run alongside the panel, matched by output name or by the start of the output's description. They are turned off before the panel comes back on lid open, and back on after it goes dark on lid close.

### Other options

- `full_name` and `email_address` have no default. Nothing reads them yet: the git module that used them is not imported.
- `primary_font` is the font family for the Ghostty terminal. Default: `"Liberation Sans 11"`.
- `quick_app_bindings` is a list of Hyprland bindings that launch common apps. The defaults are in `config.nix`; setting the option replaces the whole list.
- `kill_app_binding` is a list of Hyprland bindings that close the active window. Default: `SUPER + W` and `SUPER + Backspace`.
- `exclude_packages` is a list of packages to leave out of the default install. Only the discretionary set in [`modules/packages.nix`](modules/packages.nix) can be excluded.
- `vscode_settings` is declared but not applied at the moment; the VS Code settings block is commented out in `modules/home-manager/vscode.nix`.

### Quickshell

The shell is configured by [`config/quickshell/config.json`](config/quickshell/config.json), not by `omarchy.*` options. Every key has a default in the loader, so a missing key or a missing file is fine.

```json
{
  "theme": { "dark": true, "accent": "Teal" },
  "bar": {
    "showWorkspaces": true, "showDate": true, "showClock": true,
    "showAudio": true, "showNetwork": true, "showPowerProfile": true,
    "showCpu": true, "showMemory": true, "showCamera": true, "showMicrophone": true,
    "privacyAlwaysShown": true
  }
}
```

- `theme.dark` selects the Material dark or light theme.
- `theme.accent` is the name of a Material predefined color.
- `bar.show*` shows or hides one bar item each.
- `bar.privacyAlwaysShown` keeps the camera and microphone indicators visible as dimmed glyphs when idle. When false they appear only while the device is in use.

The installed copy under `~/.config/quickshell` is a read-only link into the Nix store. Edit the file in this repo and rebuild, or run the shell from the working tree as described below.

`SUPER + SHIFT + space` toggles the bar.

## Development

The dev shell provides `qs`, `qmlformat` and `qmlls`:

```sh
nix develop
systemctl --user stop quickshell      # the installed shell would otherwise run alongside yours
qs -p config/quickshell               # the whole shell, from the working tree
qs -p config/quickshell/dev-bar.qml   # the bar slice alone
systemctl --user start quickshell     # back to the installed copy
```

`qs` needs a running Hyprland session. When it runs from the working tree, saving a QML file reloads the shell and saving `config.json` makes it re-read the values. The conventions for working in the tree are in [`docs/quickshell-architecture.md`](docs/quickshell-architecture.md) and [`config/quickshell/AGENTS.md`](config/quickshell/AGENTS.md).

`nix fmt` formats the Nix files. The dev shell and the formatter are defined for `x86_64-linux` only; the two modules are not tied to a system.

## License

The upstream project describes itself as released under the MIT License, same as the original Omarchy. This repository does not ship a LICENSE file of its own. `modules/nixos/t2-dsp.nix` carries its own MIT notice from the Asahi Linux contributors.
