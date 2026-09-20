inputs:
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.omarchy;
in
{
  imports = [
    ./autostart.nix
    ./bindings.nix
    ./envs.nix
    (import ./hyprmod.nix inputs)
    ./input.nix
    ./looknfeel.nix
    ./windows.nix
  ];
}
