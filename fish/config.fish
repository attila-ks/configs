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
--color=bg+:#363636,bg:#222222,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

alias cat="bat"
alias tp="trash-put"

# The alias is needed for the Helix editor to be able to open .html files in the browser on both Linux and WSL.
if type -q explorer.exe
    alias browser="explorer.exe"
else
    alias browser="xdg-open"
end

fish_add_path /home/"$USER"/.local/bin
fish_add_path /home/"$USER"/.cargo/bin
