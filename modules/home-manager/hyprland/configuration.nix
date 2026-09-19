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
    ./input.nix
    ./looknfeel.nix
    ./windows.nix
  ];
}
