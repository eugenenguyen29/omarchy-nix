#!/usr/bin/env bash

# Power menu rendered by walker in dmenu mode.
# Session actions are handed to systemd (logind), locking to hyprlock.

set -euo pipefail

options="  Lock
  Logout
  Suspend
  Reboot
  Shutdown"

choice=$(printf '%s\n' "$options" | walker --dmenu --exit --theme nixos --placeholder "Power" || true)

case "${choice##* }" in
Lock) hyprlock ;;
Logout) loginctl terminate-session "${XDG_SESSION_ID:-self}" ;;
Suspend) systemctl suspend ;;
Reboot) systemctl reboot ;;
Shutdown) systemctl poweroff ;;
*) exit 0 ;;
esac
