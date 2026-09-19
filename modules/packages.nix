{
  pkgs,
  lib,
  exclude_packages ? [ ],
}:
let
  disable-apple-trackpad = pkgs.writeScriptBin "disable-apple-trackpad" (
    builtins.readFile ../scripts/disable-apple-trackpad.sh
  );

  omarchy-show-keybindings = pkgs.writeScriptBin "omarchy-show-keybindings" (
    builtins.readFile ../scripts/omarchy-show-keybindings.sh
  );

  omarchy-power-menu = pkgs.writeScriptBin "omarchy-power-menu" (
    builtins.readFile ../scripts/omarchy-power-menu.sh
  );

  customScripts = [
    disable-apple-trackpad
    omarchy-show-keybindings
    omarchy-power-menu
  ];

  # Essential Hyprland packages - cannot be excluded
  hyprlandPackages = with pkgs; [
    hyprshot
    hyprpicker
    hyprsunset
    brightnessctl
    pamixer
    playerctl
    gnome-themes-extra
    pavucontrol
  ];

  lowlevelPackages = with pkgs; [
    bluez
    bluetui

    docker-compose
  ];

  # Essential system packages - cannot be excluded
  systemPackages = with pkgs; [
    git
    vim
    libnotify
    nautilus
    alejandra

    clipse
    fzf
    zoxide
    ripgrep
    eza
    fd
    curl
    unzip
    wget
    gnumake
  ];

  # Discretionary packages - can be excluded by user
  discretionaryPackages =
    with pkgs;
    [
      # TUIs
      lazygit
      lazydocker
      btop
      powertop
      fastfetch

      # GUIs
      chromium
      #obsidian
      vlc
      signal-desktop

      # Development tools
      github-desktop
      gh

      ffmpeg
    ]
    ++ lib.optionals (pkgs.stdenv.hostPlatform.system == "x86_64-linux") [
    ];

  # Only allow excluding discretionary packages to prevent breaking the system
  filteredDiscretionaryPackages = lib.lists.subtractLists exclude_packages discretionaryPackages;
  allSystemPackages =
    hyprlandPackages
    ++ systemPackages
    ++ filteredDiscretionaryPackages
    ++ customScripts
    ++ lowlevelPackages;
in
{
  # Regular packages
  systemPackages = allSystemPackages;

  homePackages = with pkgs; [
  ];
}
