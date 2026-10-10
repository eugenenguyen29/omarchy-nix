# omarchy.lid backend for Hyprland: lid closed on a docked laptop drops to the
# external monitors only; lid open brings the panel back, first turning off any
# exclusive monitor that would starve it of bandwidth.
#
# logind never suspends on lid close when docked, so the session keeps running --
# but nothing turns the built-in panel off, leaving windows stranded on a screen
# nobody can see. Hyprland owns the output, not logind, so the switch has to be
# handled here.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.omarchy.lid;
  panel = cfg.internal_monitor;
  exclusive = lib.escapeShellArgs cfg.exclusive_monitors;

  # config.wayland...package, not pkgs.hyprland: the latter is nixpkgs' build and
  # differs from the flake's, which would stage a second full Hyprland closure
  # just to get hyprctl. The path is bound to a shell variable at the top of each
  # script rather than interpolated at the call site: it carries a "+date=" in
  # its name, which shellcheck reads as an assignment prefix (SC2276) and rejects.
  #
  # hyprland-gui.conf is HyprMod-managed and holds the only monitor rules (mode,
  # scale, position, colour management), so they are read back rather than
  # duplicated here -- a copy would silently rot the next time the GUI writes it.
  # A `disable` rule is skipped: it is what the GUI leaves behind for an output
  # turned off by hand, and re-applying it is the opposite of restoring it.
  # When HyprMod has no usable rule (the panel's is `disable` after a save under a
  # closed lid, or the dock renumbered DP-n), the nix-declared `omarchy.monitors`
  # entry matching the output's description (or name) is used instead.
  #
  # No `hyprctl reload` anywhere: it re-applies that file wholesale, which would
  # switch the exclusive monitor straight back on (and the panel off). Reloads
  # from elsewhere are caught by the `exec` below instead.
  common = ''
    hyprctl="${hyprctl}"
    exclusive=(${exclusive})
    monitors=(${lib.escapeShellArgs config.omarchy.monitors})

    # Names of connected outputs matching any argument, by name or description prefix.
    outputs() {
      "$hyprctl" -j monitors all | jq -r --args '.[]
        | select(.name as $n | .description as $d
            | any($ARGS.positional[]; . as $a | $n == $a or ($d | startswith($a))))
        | .name' "$@"
    }

    rule() {
      local r d m
      r=$(grep -h "^monitor *= *$1 *," "$HOME/.config/hypr/hyprland-gui.conf" 2>/dev/null \
        | grep -v ', *disable *$' | tail -1 | sed 's/^monitor *= *//' || true)
      [ -n "$r" ] && { echo "$r"; return; }
      d=$("$hyprctl" -j monitors all | jq -r --arg n "$1" '.[] | select(.name == $n) | .description')
      for m in "''${monitors[@]}"; do
        if [[ "''${m%%,*}" == "desc:$d" || "''${m%%,*}" == "$1" ]]; then echo "$m"; return; fi
      done
    }

    # `keyword monitor` only queues the change for Hyprland's next tick, so the
    # bandwidth is not free yet when it returns.
    # ponytail: 2s ceiling, raise it if a slow dock takes longer to release the link.
    wait_disabled() {
      for _ in $(seq 20); do
        [ "$("$hyprctl" -j monitors all | jq --arg n "$1" '.[] | select(.name == $n) | .disabled')" = true ] && return
        sleep 0.1
      done
    }
  '';

  hyprctl = lib.getExe' config.wayland.windowManager.hyprland.package "hyprctl";
  runtimeInputs = with pkgs; [
    jq
    gnugrep
    gnused
    coreutils
  ];

  # The panel is only disabled when something else is left to draw on. Disabling
  # the last output drops Hyprland onto its headless fallback, which is a far
  # worse state to be in than a lid closed over a still-lit screen. Exclusive
  # monitors count -- they are connected, just waiting for the panel to go dark.
  lidClose = pkgs.writeShellApplication {
    name = "hypr-lid-close";
    inherit runtimeInputs;
    text = common + ''
      others=$("$hyprctl" -j monitors all | jq '[.[] | select(.name != "${panel}")] | length')
      [ "$others" -gt 0 ] || exit 0

      "$hyprctl" keyword monitor "${panel}, disable"
      wait_disabled "${panel}"
      for out in $(outputs "''${exclusive[@]}"); do
        r=$(rule "$out")
        "$hyprctl" keyword monitor "''${r:-$out, preferred, auto, 1}"
      done
    '';
  };

  lidOpen = pkgs.writeShellApplication {
    name = "hypr-lid-open";
    inherit runtimeInputs;
    text = common + ''
      for out in $(outputs "''${exclusive[@]}"); do
        "$hyprctl" keyword monitor "$out, disable"
        wait_disabled "$out"
      done

      r=$(rule "${panel}")
      "$hyprctl" keyword monitor "''${r:-${panel}, preferred, auto, ${toString config.omarchy.scale}}"
    '';
  };
in
{
  config = lib.mkIf (cfg.enable && cfg.backend == "hyprland") {
    # bindl fires while the session is locked, which is exactly when the lid moves.
    wayland.windowManager.hyprland.settings.bindl = [
      ", switch:on:Lid Switch, exec, ${lib.getExe lidClose}"
      ", switch:off:Lid Switch, exec, ${lib.getExe lidOpen}"
    ];

    # A reload re-applies hyprland-gui.conf wholesale, which disagrees with the
    # lid either way: the panel's rule lights it under a closed lid, and a
    # `disable` HyprMod saved while the lid was shut (plus the exclusive monitor's
    # rule) blanks it under an open one. HyprMod reloads on every launch and
    # save, home-manager on every switch. `exec` (unlike exec-once) re-runs after
    # each reload, and at login, so the lid's actual state is re-asserted each time.
    wayland.windowManager.hyprland.settings.exec = [
      "if ${lib.getExe' pkgs.gnugrep "grep"} -qs closed /proc/acpi/button/lid/*/state; then ${lib.getExe lidClose}; else ${lib.getExe lidOpen}; fi"
    ];
  };
}
