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
}

function install_meson() {
	echo -e "\n${GREEN}Installing Meson...${NO_COLOR}"

	case $package_manager in
	dnf | zypper)
		sudo $package_manager install -y meson
		;;
	esac
}

function install_ripgrep() {
	echo -e "\n${GREEN}Installing ripgrep (an alternative to 'grep')...${NO_COLOR}"

	case $package_manager in
	dnf | zypper)
		sudo $package_manager install -y ripgrep
		;;
	esac
}

function install_fd() {
	echo -e "\n${GREEN}Installing fd (an alternative to 'find')...${NO_COLOR}"

	case $package_manager in
	dnf | zypper)
		sudo $package_manager install -y fd
		;;
	esac
}

function install_npm() {
	echo -e "\n${GREEN}Installing npm...${NO_COLOR}"

	case $package_manager in
	dnf | zypper)
		sudo $package_manager install -y npm
		;;
	esac
}

USER=$(whoami)

function install_lf_file_manager() {
	echo -e "\n${GREEN}Installing lf file manager...${NO_COLOR}"

	case $package_manager in
	dnf | zypper)
		sudo $package_manager install -y lf
		;;
	esac

	ln -s "$(pwd)"/lf /home/"$USER"/.config/
}

function install_bat() {
	echo -e "\n${GREEN}Install bat (an alternative to 'cat')...${NO_COLOR}"

	case $package_manager in
	dnf | zypper)
		sudo $package_manager install -y bat
		;;
	esac

	ln -s "$(pwd)"/bat /home/"$USER"/.config/
	# TODO: Use `curl` to download `catppuccin-mocha` theme
	bat cache --build
}

function install_cpp_tools() {
	echo -e "\n${GREEN}Installing C++ tools (clangd, clang-format, codelldb)...${NO_COLOR}"

	case $package_manager in
	dnf | zypper)
		sudo $package_manager install -y clang-tools-extra
		;;
	esac

	# `lldb-vscode` has been renamed to `lldb-dap`, but Helix editor looks for the former.
	ln -s /usr/bin/lldb-dap /usr/bin/lldb-vscode
}

function install_meson_lsp() {
	echo -e "\n${GREEN}Installing Meson LSP...${NO_COLOR}"
	# Helix currently has no built-in support for Meson.
}

function install_bash_lsp() {
	echo -e "\n${GREEN}Installing Bash LSP...${NO_COLOR}"
	install_npm

	sudo npm install -g bash-language-server
}

function install_helix_editor() {
	echo -e "\n${GREEN}Installing language tools for Helix editor...${NO_COLOR}"
	install_cpp_tools
	install_meson_lsp
	install_bash_lsp

	echo -e "\n${GREEN}Installing Helix editor...${NO_COLOR}"

	case $package_manager in
	dnf | zypper)
		sudo $package_manager install -y helix
		;;
	esac

	ln -s "$(pwd)"/helix/config.toml /home/"$USER"/.config/helix/
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
	# TODO: Use `curl` to download the `catppuccin-mocha` theme
	ln -s "$(pwd)"/fish/themes /home/"$USER"/.config/fish/
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

detect_installed_package_manager
install_git
install_meson
install_fish_shell
install_lf_file_manager
install_bat
install_zoxide
install_tmux
install_starship_prompt
install_fzf
install_trash_cli
install_helix_editor
install_tealdeer
