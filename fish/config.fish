if status is-interactive
    # Commands to run in interactive sessions can go here
    if not set -q TMUX
        exec tmux
    end

    zoxide init --cmd j fish | source
    starship init fish | source
end

# Set Catppuccin Mocha colorscheme for fzf
set -Ux FZF_DEFAULT_OPTS "\
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
