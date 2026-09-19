#!/usr/bin/env bash

# Power menu rendered by wofi in dmenu mode.
# Session actions are handed to systemd (logind), locking to hyprlock.

set -euo pipefail

options="  Lock
  Logout
  Suspend
  Reboot
  Shutdown"

# -k /dev/null keeps wofi from reordering entries by usage.
choice=$(printf '%s\n' "$options" |
  wofi --dmenu --prompt "Power" --insensitive --no-custom-entry \
    --lines 5 --width 300 --cache-file /dev/null || true)

case "${choice##* }" in
Lock) hyprlock ;;
Logout) loginctl terminate-session "${XDG_SESSION_ID:-self}" ;;
Suspend) systemctl suspend ;;
Reboot) systemctl reboot ;;
Shutdown) systemctl poweroff ;;
*) exit 0 ;;
esac
