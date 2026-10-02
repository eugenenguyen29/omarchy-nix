{ config, lib, ... }:
{
  programs = {
    _1password.enable = true;
    _1password-gui.enable = true;

    _1password-gui.polkitPolicyOwners = builtins.attrNames (
      lib.filterAttrs (_: u: u.isNormalUser) config.users.users
    );
  };

  # 1Password keeps its device session in the Secret Service keyring;
  # without one it forgets the sign-in on every reboot.
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  # Keyring only; SSH keys come from the 1Password agent.
  services.gnome.gcr-ssh-agent.enable = false;
}
