{ ... }:

{
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "";
    };
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = builtins.readFile ./custom.zsh;
    shellAliases = {
      ls = "eza -lh --group-directories-first --icons=auto";
      lsa = "eza -lha --group-directories-first --icons=auto";
      lt = "eza --tree --level=2 --long --icons --git";
      lta = "eza --tree --level=2 --long --icons --git -a";
      nv = "nvim";
    };
  };
}
