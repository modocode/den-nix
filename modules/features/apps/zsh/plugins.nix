{pkgs, ...}:
[
  {
    name = "zsh-fzh-tab";
    src = "${pkgs.zsh-fzf-tab}";
  }

  {
    name = "zsh-edit";
    src = "${pkgs.zsh-edit}/share/zsh/zsh-edit";
  }
]
