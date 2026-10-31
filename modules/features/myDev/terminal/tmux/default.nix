{ ... }:

{
  flake.nixosModules.tmux = {pkgs, ...}:
    {
    programs.tmux = {
      enable = true;
      terminal = "tmux-256color";
      baseIndex = 1;
      historyLimit = 50000;
      escapeTime = 10;
      keyMode = "vi";
      customPaneNavigationAndResize = true;
      clock24 = true;

      extraConfig = ''
        set -g mouse on
        set -g renumber-windows on
        set -g focus-events on
        set -g set-clipboard external
        set -as terminal-features ',xterm-ghostty:RGB,xterm-256color:RGB'

        # Prefix is Ctrl-b. Open splits and windows in the current directory.
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"
        bind c new-window -c "#{pane_current_path}"

        bind -n M-h select-pane -L
        bind -n M-j select-pane -D
        bind -n M-k select-pane -U
        bind -n M-l select-pane -R
        bind-key "T" run-shell "sesh connect \"$(
          sesh list --icons | fzf-tmux -p 80%,70% \
            --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
            --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
            --bind 'tab:down,btab:up' \
            --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
            --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
            --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
            --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
            --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
            --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
            --preview-window 'right:55%' \
            --preview 'sesh preview {}'
        )\"

        # Vim-style selection in copy mode (prefix + [).
        bind -T copy-mode-vi v send-keys -X begin-selection
        bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel

        # Reload the system configuration after rebuilding.
        bind r source-file /etc/tmux.conf \; display-message "tmux config reloaded"

        # Compact status bar: session, windows, date and time.
        set -g status-style 'bg=default,fg=colour245'
        set -g status-left '#[fg=colour75,bold] #S #[default]'
        set -g status-left-length 30
        set -g status-right '%Y-%m-%d %H:%M '
        setw -g window-status-format ' #I:#W '
        setw -g window-status-current-format '#[fg=colour75,bold] #I:#W #[default]'
      '';
    };

    environment.systemPackages = with pkgs; [
      sesh 
    ];
    };
   
}
