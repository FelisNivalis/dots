unbind-key -n C-q
unbind-key -n C-z
set -g prefix F12
unbind-key -n C-a

bind -n Home send Escape "[H"
bind -n End send Escape "[F"
unbind -n S-Left  # rebind select-pane to Ctrl+Shift+Arrow
unbind -n S-Right # because Shift+Arrow was used in Vim
unbind -n S-Up
unbind -n S-Down
bind -n C-S-Left select-pane -L
bind -n C-S-Right select-pane -R
bind -n C-S-Up select-pane -U
bind -n C-S-Down select-pane -D
bind -n F2 new-window # Override Byobu's default binding which names the new window "-"
bind -n C-S-F2 new-session
bind R source-file $BYOBU_CONFIG_DIR/.tmux.conf \; display-message "Config .tmux.conf reloaded..."
