inputs:
{
  config,
  pkgs,
  ...
}:
let
  cfg = config.omarchy;
  packages = import ../packages.nix { inherit pkgs; };
in
{
  imports = [
    (import ./hyprland.nix inputs)
    (import ./system.nix)
    (import ./1password.nix)
    (import ./containers.nix)
    (import ./greeter.nix)
  ];

  t2AppleAudioDSP = {
    enable = true;
    model = "15_4";
  };
}
