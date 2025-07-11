#!/bin/bash

# TODO: Exit functions on error.
# TODO: Check if packages are already installed.
# TODO: Hide redundant outputs.
# TODO: Install Markdown linter for Helix editor.
# TODO: Add Copilot support for Helix editor.
# TODO: Add TOML LSP support for Helix editor.
# TODO: Add Harper spell checker support for Helix editor.
# TODO: Add Rust support for Helix editor.
# TODO: Consider to add a Git tool for Helix editor or terminal.
# FIXME: ruff installation fails on Ubuntu
# FIXME: Shell must be restarted after installing Rust.

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
	elif [ -x "$(command -v apt)" ]; then
		package_manager="apt"
	else
		echo -e "\n${RED}Package manager detection failed. Exiting...${NO_COLOR}"
		exit 1
	fi

	echo -e "\n${GREEN}Detected package manager: $package_manager${NO_COLOR}"
}

function install_git() {
	echo -e "\n${GREEN}Installing Git...${NO_COLOR}"

	local error

	error=$(sudo $package_manager install -y git 2>&1) || {
		echo -e "\n\t${RED}Git installation failed:${NO_COLOR} ${error}"
	}

	# FIXME: The following command fails because .gitconfig is added to .gitignore
	ln -s "$(pwd)"/git/.gitconfig "$HOME"/
}

function install_yazi_file_manager() {
	echo -e "\n${GREEN}Installing Yazi file manager...${NO_COLOR}"

	local error

	echo -e "\n\t${GREEN}Installing optional extensions...${NO_COLOR}"

	error=$(sudo $package_manager install -y jq poppler fd rg 2>&1) || {
		echo -e "\n\t\t${RED}Optional extension(s) installation failed:${NO_COLOR} ${error}"
	}

	error=$(cargo install --locked yazi-fm yazi-cli 2>&1) || {
		echo -e "\n\t${RED}Yazi installation failed:${NO_COLOR} ${error}"
	}

	ln -s "$(pwd)"/yazi/yazi.toml /home/"$USER"/.config/yazi/
	ln -s "$(pwd)"/fish/functions/y.fish /home/"$USER"/.config/fish/functions/
}

function install_bat() {
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

	ln -s "$(pwd)"/bat /home/"$USER"/.config/
	$bat cache --build
}

function install_helix_editor() {
	echo -e "\n${GREEN}Installing Helix editor...${NO_COLOR}"

	local error

	error=$(sudo $package_manager install -y helix 2>&1) || {
		echo -e "\n\t${RED}Helix installation failed:${NO_COLOR} ${error}"
	}

	ln -s "$(pwd)"/helix/config.toml /home/"$USER"/.config/helix/
	ln -s "$(pwd)"/helix/languages.toml /home/"$USER"/.config/helix/

	install_rust_toolchain
	install_yazi_file_manager
	install_glow
	install_python_lsp
	install_bash_lsp
	install_fish_lsp
	install_search_and_replace_tool
}

function install_tmux() {
	echo -e "\n${GREEN}Installing tmux...${NO_COLOR}"

	local error

	error=$(sudo $package_manager install -y tmux 2>&1) || {
		echo -e "\n\t${RED}Tmux installation failed:${NO_COLOR} ${error}"
	}

	ln -s "$(pwd)"/tmux/.tmux.conf /home/"$USER"/

	if [ ! -d "/home/$USER/.config/tmux/plugins" ]; then
		mkdir -p /home/"$USER"/.config/tmux/plugins
	fi

	git clone https://github.com/catppuccin/tmux.git /home/"$USER"/.config/tmux/plugins/catppuccin
}

function install_starship_prompt() {
	echo -e "\n${GREEN}Installing Starship prompt...${NO_COLOR}"

	local error

	error=$(curl -sS https://starship.rs/install.sh | sh -s -- --yes 2>&1) || {
		echo -e "\n\t${RED}Starship prompt installation failed:${NO_COLOR} ${error}"
	}

	ln -s "$(pwd)"/starship.toml /home/"$USER"/.config/
}

function install_fzf() {
	echo -e "\n${GREEN}Installing fzf...${NO_COLOR}"

	local error

	error=$(sudo $package_manager install -y fzf 2>&1) || {
		echo -e "\n\t${RED}fzf installation failed:${NO_COLOR} ${error}"
	}
}

function install_trash_cli() {
	echo -e "\n${GREEN}Installing trash-cli...${NO_COLOR}"

	echo -e "\n\t${GREEN}Installing pipx dependency...${NO_COLOR}"
	local error

	error=$(sudo $package_manager install -y pipx 2>&1) || {
		echo -e "\n\t\t${RED}pipx installation failed:${NO_COLOR} ${error}"
	}

	pipx ensurepath

	error=$(pipx install trash-cli 2>&1) || {
		echo -e "\n\t${RED}trash-cli installation failed:${NO_COLOR} ${error}"
	}
}

function install_fish_shell() {
	echo -e "\n${GREEN}Installing fish shell...${NO_COLOR}"

	local error

	error=$(sudo $package_manager install -y fish 2>&1) || {
		echo -e "\n\t${RED}Fish shell installation failed:${NO_COLOR} ${error}"
	}

	if [ ! -d /home/"$USER"/.config/fish ]; then
		mkdir /home/"$USER"/.config/fish
	elif [ -e /home/"$USER"/.config/fish/config.fish ]; then
		trash-put /home/"$USER"/.config/fish/config.fish
	fi

	ln -s "$(pwd)"/fish/config.fish /home/"$USER"/.config/fish/
	ln -s "$(pwd)"/fish/themes /home/"$USER"/.config/fish/
	# Disables fish's welcome message.
	fish -c 'set -U fish_greeting'
	# Sets the Fish shell as the default shell.
	chsh -s /usr/bin/fish
}

function install_zoxide() {
	echo -e "\n${GREEN}Installing zoxide...${NO_COLOR}"

	local error

	error=$(sudo $package_manager install -y zoxide 2>&1) || {
		echo -e "\n\t${RED}zoxide installation failed:${NO_COLOR} ${error}"
	}
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
	echo -e "\n${GREEN}Installing Alacritty...${NO_COLOR}"

	local error

	error=$(sudo $package_manager install -y alacritty 2>&1) || {
		echo -e "\n\t${RED}Alacritty installation failed:${NO_COLOR} ${error}"
	}

	if [ ! -d /home/"$USER"/.config/alacritty ]; then
		mkdir /home/"$USER"/.config/alacritty
	fi

	ln -s "$(pwd)"/alacritty/alacritty.toml /home/"$USER"/.config/alacritty/
	mkdir /home/"$USER"/.config/alacritty/themes
	cd /home/"$USER"/.config/alacritty/themes
	error=$(curl -LO https://github.com/catppuccin/alacritty/raw/main/catppuccin-mocha.toml 2>&1) || {
		echo -e "\n\t${RED}Downloading Alacritty theme failed:${NO_COLOR} ${error}"
	}
	cd -
}

function install_tealdeer() {
	echo -e "\n${GREEN}Installing tealdeer...${NO_COLOR}"

	local error

	error=$(sudo $package_manager install -y tealdeer 2>&1) || {
		echo -e "\n\t${RED}tealdeer installation failed:${NO_COLOR} ${error}"
	}

	echo -e "\n${GREEN}Updating tealdeer cache...${NO_COLOR}"
	tldr --update
}

function install_glow() {
	echo -e "\n${GREEN}Installing Glow markdown reader...${NO_COLOR}"

	local error

	if [ $package_manager = "apt" ]; then
		error=$(sudo snap install -y glow 2>&1) || {
			echo -e "\n\t${RED}Glow installation failed:${NO_COLOR} ${error}"
		}
	else
		error=$(sudo $package_manager install -y glow 2>&1) || {
			echo -e "\n\t${RED}Glow installation failed:${NO_COLOR} ${error}"
		}
	fi
}

function install_python_lsp() {
	echo -e "\n${GREEN}Installing ruff Python LSP...${NO_COLOR}"

	local error

	error=$(pip install ruff 2>&1) || {
		echo -e "\n\t${RED}ruff installation failed:${NO_COLOR} ${error}"
	}
}

function install_bash_lsp() {
	echo -e "\n${GREEN}Installing Bash LSP...${NO_COLOR}"

	local error

	echo -e "\n\t${GREEN}Installing shellcheck dependency...${NO_COLOR}"
	error=$(sudo $package_manager install -y shellcheck 2>&1) || {
		echo -e "\n\t${RED}shellcheck installation failed:${NO_COLOR} ${error}"
	}
	echo -e "\n\t${GREEN}Installing npm dependency...${NO_COLOR}"
	error=$(sudo $package_manager install -y npm 2>&1) || {
		echo -e "\n\t${RED}npm installation failed:${NO_COLOR} ${error}"
	}

	error=$(sudo npm install -g bash-language-server 2>&1) || {
		echo -e "\n\t${RED}Bash LSP installation failed:${NO_COLOR} ${error}"
	}
}

function install_fish_lsp() {
	echo -e "\n${GREEN}Installing Fish LSP...${NO_COLOR}"

	local error

	error=$(sudo npm install -g fish-lsp 2>&1) || {
		echo -e "\n\t${RED}Fish LSP installation failed:${NO_COLOR} ${error}"
	}

	fish-lsp complete >~/.config/fish/completions/fish-lsp.fish
}

function install_search_and_replace_tool() {
	echo -e "\n${GREEN}Installing Scooter (search and replace tool)...${NO_COLOR}"

	local error

	error=$(cargo install scooter --locked 2>&1) || {
		echo -e "\n\t${RED}Scooter installation failed:${NO_COLOR} ${error}"
	}
}

function install_rust_toolchain() {
	echo -e "\n${GREEN}Installing Rust toolchain...${NO_COLOR}"

	local error

	error=$(curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y 2>&1) || {
		echo -e "\n\t${RED}Rust toolchain installation failed:${NO_COLOR} ${error}"
	}

	rustup update
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
install_fish_shell
install_helix_editor
