if status is-interactive
    # Commands to run in interactive sessions can go here
    if not set -q TMUX
      exec tmux
    end

    zoxide init --cmd j fish | source
    starship init fish | source
end
