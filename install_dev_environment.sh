#!/bin/bash

# TODO: Exit functions on error.
# TODO: Hide redundant outputs.
# TODO: Update tmux's Catppuccin theme too.
# FIXME: Shell must be restarted after installing Rust.
# FIXME: npm command not found on Ubuntu
# FIXME: fish command not found error on Ubuntu
# FIXME: Switching between master and work branches breaks the colorsceme of the terminal on both Linux and WSL.

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NO_COLOR='\033[0m'

package_manager=""
postinstall_manual_steps=""

function is_package_installed() {
    local pkg="$1"

    if command -v "$pkg" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

function detect_installed_package_manager() {
    echo -e "\n${GREEN}Detecting installed package manager...${NO_COLOR}"

    if [ -x "$(command -v dnf)" ]; then
        package_manager="dnf"
    elif [ -x "$(command -v zypper)" ]; then
        package_manager="zypper"
    elif [ -x "$(command -v apt)" ]; then
        package_manager="apt"
    else
        echo -e "\n${RED}Package manager detection failed. Exiting...${NO_COLOR}"
        exit 1
    fi

    echo -e "\n${GREEN}Detected package manager: $package_manager${NO_COLOR}"
}

function install_git() {
    if ! is_package_installed git; then
        echo -e "\n${GREEN}Installing Git...${NO_COLOR}"

        local error

        error=$(sudo $package_manager install -y git 2>&1) || {
            echo -e "\n\t${RED}Git installation failed:${NO_COLOR} ${error}"
        }
    fi

    postinstall_manual_steps+="\n\t- Configure your Git user name and email address\n"
}

function install_bat() {
    if ! is_package_installed bat; then
        echo -e "\n${GREEN}Installing bat (an alternative to cat)...${NO_COLOR}"

        local error

        error=$(sudo $package_manager install -y bat 2>&1) || {
            echo -e "\n\t${RED}bat installation failed:${NO_COLOR} ${error}"
        }

        local bat="bat"

        if [ $package_manager = "apt" ]; then
            bat="batcat"
            fish -c 'alias --save bat=batcat'
        fi
    fi

    if [ ! -d /home/"$USER"/.config/bat ]; then
        ln -s "$(pwd)"/bat /home/"$USER"/.config/
    fi

    $bat cache --build
}

function install_tmux() {
    if ! is_package_installed tmux; then
        echo -e "\n${GREEN}Installing tmux...${NO_COLOR}"

        local error

        error=$(sudo $package_manager install -y tmux 2>&1) || {
            echo -e "\n\t${RED}Tmux installation failed:${NO_COLOR} ${error}"
        }
    fi

    if [ ! -e /home/"$USER"/.tmux.conf ]; then
        ln -s "$(pwd)"/tmux/.tmux.conf /home/"$USER"/
    fi

    if [ ! -d "/home/$USER/.config/tmux/plugins" ]; then
        mkdir -p /home/"$USER"/.config/tmux/plugins
    fi

    git clone https://github.com/catppuccin/tmux.git /home/"$USER"/.config/tmux/plugins/catppuccin
}

function install_starship_prompt() {
    if ! is_package_installed starship; then
        echo -e "\n${GREEN}Installing Starship prompt...${NO_COLOR}"

        local error

        error=$(curl -sS https://starship.rs/install.sh | sh -s -- --yes 2>&1) || {
            echo -e "\n\t${RED}Starship prompt installation failed:${NO_COLOR} ${error}"
        }
    fi

    if [ ! -e /home/"$USER"/.config/starship.toml ]; then
        ln -s "$(pwd)"/starship.toml /home/"$USER"/.config/
    fi
}

function install_fzf() {
    if ! is_package_installed fzf; then
        echo -e "\n${GREEN}Installing fzf...${NO_COLOR}"

        local error

        error=$(sudo $package_manager install -y fzf 2>&1) || {
            echo -e "\n\t${RED}fzf installation failed:${NO_COLOR} ${error}"
        }
    fi
}

function install_trash_cli() {
    if ! is_package_installed trash; then
        echo -e "\n${GREEN}Installing trash-cli...${NO_COLOR}"

        local error

        if ! is_package_installed pipx; then
            echo -e "\n\t${GREEN}Installing pipx dependency...${NO_COLOR}"

            error=$(sudo $package_manager install -y pipx 2>&1) || {
                echo -e "\n\t\t${RED}pipx installation failed:${NO_COLOR} ${error}"
            }

            pipx ensurepath
        fi

        error=$(pipx install trash-cli 2>&1) || {
            echo -e "\n\t${RED}trash-cli installation failed:${NO_COLOR} ${error}"
        }
    fi
}

function install_fish_shell() {
    if ! is_package_installed fish; then
        echo -e "\n${GREEN}Installing fish shell...${NO_COLOR}"

        local error

        error=$(sudo $package_manager install -y fish 2>&1) || {
            echo -e "\n\t${RED}Fish shell installation failed:${NO_COLOR} ${error}"
        }

        # Disables fish's welcome message.
        fish -c 'set -U fish_greeting'
        # Sets the Fish shell as the default shell.
        chsh -s /usr/bin/fish
    fi

    if [ ! -d /home/"$USER"/.config/fish ]; then
        mkdir /home/"$USER"/.config/fish
    elif [ -e /home/"$USER"/.config/fish/config.fish ]; then
        trash-put /home/"$USER"/.config/fish/config.fish
    fi

    if [ ! -e /home/"$USER"/.config/fish/config.fish ]; then
        ln -s "$(pwd)"/fish/config.fish /home/"$USER"/.config/fish/
    fi
    if [ ! -e /home/"$USER"/.config/fish/themes ]; then
        ln -s "$(pwd)"/fish/themes /home/"$USER"/.config/fish/
    fi
}

function install_zoxide() {
    if ! is_package_installed zoxide; then
        echo -e "\n${GREEN}Installing zoxide...${NO_COLOR}"

        local error

        error=$(sudo $package_manager install -y zoxide 2>&1) || {
            echo -e "\n\t${RED}zoxide installation failed:${NO_COLOR} ${error}"
        }
    fi
}

function install_font() {
    echo -e "\n${GREEN}Installing JetBrainsMono font...${NO_COLOR}"

    if [ ! -d /home/"$USER"/.fonts ]; then
        mkdir /home/"$USER"/.fonts
    fi

    local error

    cd /home/"$USER"/.fonts
    error=$(curl -LO https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/JetBrainsMono/NoLigatures/Regular/JetBrainsMonoNLNerdFont-Regular.ttf 2>&1) || {
        echo -e "\n\t${RED}Downloading JetBrainsMono failed:${NO_COLOR} ${error}"
    }
    cd -
}

function install_alacritty() {
    if ! is_package_installed alacritty; then
        echo -e "\n${GREEN}Installing Alacritty...${NO_COLOR}"

        local error

        error=$(sudo $package_manager install -y alacritty 2>&1) || {
            echo -e "\n\t${RED}Alacritty installation failed:${NO_COLOR} ${error}"
        }
    fi

    if [ ! -d /home/"$USER"/.config/alacritty ]; then
        mkdir /home/"$USER"/.config/alacritty
    fi

    if [ ! -e /home/"$USER"/.config/alacritty/alacritty.toml ]; then
        ln -s "$(pwd)"/alacritty/alacritty.toml /home/"$USER"/.config/alacritty/
    fi

    if [ ! -d /home/"$USER"/.config/alacritty/themes ]; then
        mkdir /home/"$USER"/.config/alacritty/themes
    fi

    if [ ! -e /home/"$USER"/.config/alacritty/themes/catppuccin-mocha.toml ]; then
        ln -s "$(pwd)"/alacritty/catppuccin-mocha.toml /home/"$USER"/.config/alacritty/themes/
    fi
}

function install_tealdeer() {
    if ! is_package_installed tldr; then
        echo -e "\n${GREEN}Installing tealdeer...${NO_COLOR}"

        local error

        error=$(sudo $package_manager install -y tealdeer 2>&1) || {
            echo -e "\n\t${RED}tealdeer installation failed:${NO_COLOR} ${error}"
        }

        echo -e "\n${GREEN}Updating tealdeer cache...${NO_COLOR}"
        tldr --update
    fi
}

function install_zed_editor() {
    if ! is_package_installed zed; then
        echo -e "\n${GREEN}Installing Zed editor...${NO_COLOR}"

        local error

        error=$(curl -f https://zed.dev/install.sh | sh 2>&1) || {
            echo -e "\n\t${RED}Zed editor installation failed:${NO_COLOR} ${error}"
        }
    fi

    if [ ! -e /home/"$USER"/.config/zed/settings.json ]; then
        ln -s "$(pwd)"/zed/settings.json /home/"$USER"/.config/zed/
    fi
}

detect_installed_package_manager
install_git
install_font
install_bat
install_zoxide
install_tmux
install_starship_prompt
install_fzf
install_trash_cli
install_alacritty
install_tealdeer
install_zed_editor
install_fish_shell

echo -e "\n${YELLOW}Post-installation manual steps:${NO_COLOR}${postinstall_manual_steps}"
