{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.omarchy;
  packages = import ../packages.nix {
    inherit pkgs lib;
    exclude_packages = cfg.exclude_packages;
  };
in
{

  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  # Install packages
  environment.systemPackages = packages.systemPackages;
  programs.direnv.enable = true;

  # Networking
  services.resolved.enable = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = lib.mkDefault false;
  networking = {
    networkmanager.enable = true;
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.caskaydia-mono
  ];

  powerManagement.powertop.enable = false; # enable powertop auto tuning on startup.

  # Use Red Hat's tuned for system performance tuning
  services.tuned.enable = true;
  services.tuned.ppdSupport = true; # Enable tuned-ppd for automatic AC/battery profile switching
  services.tuned.settings.dynamic_tuning = true; # Monitor workload and adjust settings dynamically
  services.upower.enable = true; # Required for tuned-ppd battery detection
  services.power-profiles-daemon.enable = false; # Conflicts with tuned
}
