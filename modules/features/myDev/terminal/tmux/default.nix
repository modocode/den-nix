{ ... }:

{
  flake.nixosModules.tmux = {
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
  };
}
