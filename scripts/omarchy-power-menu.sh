#!/usr/bin/env bash

# Power menu rendered by wofi in dmenu mode.
# Session actions are handed to systemd (logind), locking to hyprlock.
#
# Icons are Nerd Font (Material Design) glyphs, colored with pango markup:
#   󰌾 lock  󰗽 logout  󰒲 suspend  󰜉 reboot  󰐥 shutdown

set -euo pipefail

conf="${XDG_CONFIG_HOME:-$HOME/.config}/wofi"
style="$conf/power.css"

# Icon colors come from the active color scheme; the defaults are only a
# fallback for when home-manager has not written the palette file.
lock_fg="#89b4fa" logout_fg="#cba6f7" suspend_fg="#89dceb"
reboot_fg="#f9e2af" shutdown_fg="#f38ba8"
# shellcheck source=/dev/null
[ -r "$conf/power-colors.sh" ] && . "$conf/power-colors.sh"

entry() { printf '<span foreground="%s">%s</span>   %s\n' "$1" "$2" "$3"; }

options="$(
  entry "$lock_fg" "󰌾" "Lock"
  entry "$logout_fg" "󰗽" "Logout"
  entry "$suspend_fg" "󰒲" "Suspend"
  entry "$reboot_fg" "󰜉" "Reboot"
  entry "$shutdown_fg" "󰐥" "Shutdown"
)"

# -k /dev/null keeps wofi from reordering entries by usage.
choice=$(printf '%s\n' "$options" |
  wofi --dmenu --prompt "Power" --insensitive --no-custom-entry \
    --allow-markup --lines 5 --width 320 --height 360 \
    --style "$style" --cache-file /dev/null || true)

case "${choice##* }" in
Lock) hyprlock ;;
Logout) loginctl terminate-session "${XDG_SESSION_ID:-self}" ;;
Suspend) systemctl suspend ;;
Reboot) systemctl reboot ;;
Shutdown) systemctl poweroff ;;
*) exit 0 ;;
esac
