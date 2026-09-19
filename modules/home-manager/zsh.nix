{ ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = false;
    zplug = {
      enable = true;
      plugins = [
        {
          name = "plugins/git";
          tags = [ "from:oh-my-zsh" ];
        }
        {
          name = "fdellwing/zsh-bat";
          tags = [ "as:command" ];
        }
      ];
    };
    initContent = ''
      autoload -Uz compinit 
      if [[ -n ${"ZDOTDIR:-$HOME"}/.zcompdump(#qN.mh+24) ]]; then
      	compinit;
      else
      	compinit -C;
      fi;
    '';
  };
}
