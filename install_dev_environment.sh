#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NO_COLOR='\033[0m'

package_manager=""

function detect_installed_package_manager() {
	echo -e "\n${GREEN}Detecting installed package manager...${NO_COLOR}"

	if [ -x "$(command -v dnf)" ]; then
		package_manager="dnf"
	elif [ -x "$(command -v zypper)" ]; then
		package_manager="zypper"
	else
		echo -e "\n${RED}Package manager detection failed. Exiting...${NO_COLOR}"
		exit 1
	fi

	echo -e "\n${GREEN}Detected package manager: $package_manager.${NO_COLOR}"
}

function install_git() {
	echo -e "\n${GREEN}Installing Git...${NO_COLOR}"

	case $package_manager in
	dnf | zypper)
		sudo $package_manager install -y git
		;;
	esac
  
	# FIXME: The following command fails because .gitconfig is added to .gitignore
  ln -s "$(pwd)"/git/.gitconfig "$HOME"/
}

function install_meson() {
	echo -e "\n${GREEN}Installing Meson build system...${NO_COLOR}"

	sudo dnf install -y meson
	sudo dnf copr enable jcwasmx86/Swift-MesonLSP
	sudo dnf install mesonlsp
}

USER=$(whoami)

function install_yazi_file_manager() {
	echo -e "\n${GREEN}Installing Yazi file manager...${NO_COLOR}"

	case $package_manager in
	dnf | zypper)
		sudo $package_manager install -y yazi
		;;
	esac

  ln -s "$(pwd)"/yazi/yazi.toml /home/"$USER"/.config/yazi/
}

function install_bat() {
	echo -e "\n${GREEN}Installing bat (an alternative to cat)...${NO_COLOR}"

	case $package_manager in
	dnf | zypper)
		sudo $package_manager install -y bat
		;;
	esac

	ln -s "$(pwd)"/bat /home/"$USER"/.config/
	bat cache --build
}

function install_helix_editor() {
	echo -e "\n${GREEN}Installing Helix editor...${NO_COLOR}"

	case $package_manager in
	dnf | zypper)
		sudo $package_manager install -y helix
		;;
	esac

	ln -s "$(pwd)"/helix/config.toml /home/"$USER"/.config/helix/
	ln -s "$(pwd)"/helix/languages.toml /home/"$USER"/.config/helix/
}

function install_tmux() {
	echo -e "\n${GREEN}Installing tmux...${NO_COLOR}"

	case $package_manager in
	dnf | zypper)
		sudo $package_manager install -y tmux
		;;
	esac

	ln -s "$(pwd)"/tmux/.tmux.conf /home/"$USER"/

	if [ ! -d "/home/$USER/.config/tmux/plugins" ]; then
		mkdir -p /home/"$USER"/.config/tmux/plugins
	fi

	git clone https://github.com/catppuccin/tmux.git /home/"$USER"/.config/tmux/plugins/catppuccin
}

function install_starship_prompt() {
	echo -e "\n${GREEN}Installing Starship prompt...${NO_COLOR}"

	case $package_manager in
	dnf | zypper)
		sudo $package_manager install -y starship
		;;
	esac

	ln -s "$(pwd)"/starship.toml /home/"$USER"/.config/
}

function install_fzf() {
	echo -e "\n${GREEN}Installing fzf...${NO_COLOR}"

	case $package_manager in
	dnf | zypper)
		sudo $package_manager install -y fzf
		;;
	esac
}

function install_trash_cli() {
	echo -e "\n${GREEN}Installing trash-cli...${NO_COLOR}"

	case $package_manager in
	dnf | zypper)
		sudo $package_manager install -y python3-pipx
		;;
	esac

	pipx install trash-cli
}

function install_fish_shell() {
	echo -e "\n${GREEN}Installing fish shell...${NO_COLOR}"

	case $package_manager in
	dnf | zypper)
		sudo $package_manager install -y fish
		;;
	esac

	if [ -e /home/"$USER"/.config/fish/config.fish ]; then
		trash-put /home/"$USER"/.config/fish/config.fish
	fi

	ln -s "$(pwd)"/fish/config.fish /home/"$USER"/.config/fish/
	ln -s "$(pwd)"/fish/themes /home/"$USER"/.config/fish/
	# Disables fish's welcome message.
	set -U fish_greeting
	# Sets the Fish shell as the default shell.
	sudo chsh -s /usr/bin/fish
}

function install_zoxide() {
	echo -e "\n${GREEN}Installing zoxide...${NO_COLOR}"

	case $package_manager in
	dnf | zypper)
		sudo $package_manager install -y zoxide
		;;
	esac
}

function install_font() {
	echo -e "\n${GREEN}Installing JetBrainsMono font...${NO_COLOR}"

	if [ ! -d /home/"$USER"/.fonts ]; then
		mkdir /home/"$USER"/.fonts
	fi

	cd /home/"$USER"/.fonts
	curl -LO https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/JetBrainsMono/NoLigatures/Regular/JetBrainsMonoNLNerdFont-Regular.ttf
	cd -
}

function install_alacritty() {
	echo -e "\n${GREEN}Installing Alacritty...${NO_COLOR}"

	case $package_manager in
	dnf | zypper)
		sudo $package_manager install -y alacritty
		;;
	esac

	if [ ! -d /home/"$USER"/.config/alacritty ]; then
		mkdir /home/"$USER"/.config/alacritty
	fi

	ln -s "$(pwd)"/alacritty/alacritty.toml /home/"$USER"/.config/alacritty/
	mkdir /home/"$USER"/.config/alacritty/themes
	cd /home/"$USER"/.config/alacritty/themes
	curl -LO https://github.com/catppuccin/alacritty/raw/main/catppuccin-mocha.toml
	cd -
}

function install_tealdeer() {
	echo -e "\n${GREEN}Installing tealdeer...${NO_COLOR}"

	case $package_manager in
	dnf | zypper)
		sudo $package_manager install -y tealdeer
		;;
	esac

	echo -e "\n${GREEN}Updating tealdeer cache...${NO_COLOR}"
	tldr --update
}

function install_glow() {
	echo -e "\n${GREEN}Installing Glow markdown reader...${NO_COLOR}"

	case $package_manager in
	dnf | zypper)
		sudo $package_manager install -y glow
		;;
	esac
}

function install_python_lsp() {
	echo -e "\n${GREEN}Installing ruff Python LSP...${NO_COLOR}"
	pip install ruff
}

function install_bash_lsp() {
	echo -e "\n${GREEN}Installing Bash LSP...${NO_COLOR}"

	case $package_manager in
	dnf | zypper)
		sudo $package_manager install -y shellcheck
		sudo $package_manager install -y npm
		;;
	esac

	sudo npm install -g bash-language-server
}

function install_fish_lsp() {
	echo -e "\n${GREEN}Installing Fish LSP...${NO_COLOR}"
	sudo npm install -g fish-lsp

	fish-lsp complete > ~/.config/fish/completions/fish-lsp.fish
}
 
detect_installed_package_manager
install_git
install_meson
install_font
install_yazi_file_manager
install_bat
install_zoxide
install_tmux
install_starship_prompt
install_fzf
install_trash_cli
install_alacritty
install_tealdeer
install_fish_shell
install_glow
install_helix_editor
install_python_lsp
install_bash_lsp
install_fish_lsp
