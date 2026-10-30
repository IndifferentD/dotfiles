{ lib, pkgs, profile, ... }:

{
  home.packages = [ pkgs.delta ];

  programs.git = {
    enable = true;
    # Optional, manually managed overrides for workspace repositories.
    includes = [
      {
        condition = "gitdir:~/workspace/";
        path = "~/.config/git/workspace.inc";
      }
    ];
    settings = {
      core = {
        autocrlf = "input";
        pager = "delta";
      };
      interactive.diffFilter = "delta --color-only";
      delta = {
        "side-by-side" = true;
        "line-numbers" = true;
        "syntax-theme" = "Dracula";
        dark = true;
        "minus-style" = "syntax #35282b";
        "minus-emph-style" = "syntax #55343b";
        "plus-style" = "syntax #27372e";
        "plus-emph-style" = "syntax #365342";
      };
      init.defaultBranch = "main";
      user = {
        name = "IndifferentD";
        email = "indifferentdensity@gmail.com";
      };
    } // lib.optionalAttrs (profile == "personal") {
      credential.helper = "store";
    };
  };
}
