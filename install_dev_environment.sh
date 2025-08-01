#!/bin/bash

# TODO: Exit functions on error.
# TODO: Hide redundant outputs.
# TODO: Install Markdown linter for Helix editor.
# TODO: Add Copilot support for Helix editor.
# TODO: Add Harper spell checker support for Helix editor.
# TODO: Add Rust support for Helix editor.
# TODO: Add missing Helix debug adapters.
# TODO: Add missing Helix formatters.
# TODO: Add missing Helix Highlights.
# TODO: Add missing Helix Textobjects.
# TODO: Add missing Helix Indents.
# FIXME: ruff installation fails on Ubuntu
# FIXME: Shell must be restarted after installing Rust.

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

function install_helix_editor() {
	if ! is_package_installed hx; then
		echo -e "\n${GREEN}Installing Helix editor...${NO_COLOR}"

		local error

		error=$(sudo $package_manager install -y helix 2>&1) || {
			echo -e "\n\t${RED}Helix installation failed:${NO_COLOR} ${error}"
		}
	fi

	if [ ! -e /home/"$USER"/.config/helix/config.toml ]; then
		ln -s "$(pwd)"/helix/config.toml /home/"$USER"/.config/helix/
	fi
	if [ ! -e /home/"$USER"/.config/helix/languages.toml ]; then
		ln -s "$(pwd)"/helix/languages.toml /home/"$USER"/.config/helix/
	fi

	install_rust_toolchain
	install_glow
	install_python_lsp
	install_bash_lsp
	install_fish_lsp
	install_toml_lsp
	install_search_and_replace_tool
	install_gitui
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

	mkdir /home/"$USER"/.config/alacritty/themes
	cd /home/"$USER"/.config/alacritty/themes
	error=$(curl -LO https://github.com/catppuccin/alacritty/raw/main/catppuccin-mocha.toml 2>&1) || {
		echo -e "\n\t${RED}Downloading Alacritty theme failed:${NO_COLOR} ${error}"
	}
	cd -
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

function install_glow() {
	if ! is_package_installed glow; then
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
	fi
}

function install_python_lsp() {
	if ! is_package_installed ruff; then
		echo -e "\n${GREEN}Installing ruff Python LSP...${NO_COLOR}"

		local error

		error=$(pip install ruff 2>&1) || {
			echo -e "\n\t${RED}ruff installation failed:${NO_COLOR} ${error}"
		}
	fi
}

function install_bash_lsp() {
	if ! is_package_installed bash-language-server; then
		echo -e "\n${GREEN}Installing Bash LSP...${NO_COLOR}"

		local error

		if ! is_package_installed shellcheck; then
			echo -e "\n\t${GREEN}Installing shellcheck dependency...${NO_COLOR}"

			error=$(sudo $package_manager install -y shellcheck 2>&1) || {
				echo -e "\n\t${RED}shellcheck installation failed:${NO_COLOR} ${error}"
			}
		fi

		if ! is_package_installed npm; then
			echo -e "\n\t${GREEN}Installing npm dependency...${NO_COLOR}"

			error=$(sudo $package_manager install -y npm 2>&1) || {
				echo -e "\n\t${RED}npm installation failed:${NO_COLOR} ${error}"
			}
		fi

		error=$(sudo npm install -g bash-language-server 2>&1) || {
			echo -e "\n\t${RED}Bash LSP installation failed:${NO_COLOR} ${error}"
		}
	fi
}

function install_fish_lsp() {
	if ! is_package_installed fish-lsp; then
		echo -e "\n${GREEN}Installing Fish LSP...${NO_COLOR}"

		local error

		error=$(sudo npm install -g fish-lsp 2>&1) || {
			echo -e "\n\t${RED}Fish LSP installation failed:${NO_COLOR} ${error}"
		}
	fi

	fish-lsp complete >~/.config/fish/completions/fish-lsp.fish
}

function install_toml_lsp() {
	if ! is_package_installed taplo; then
		echo -e "\n${GREEN}Installing TOML LSP...${NO_COLOR}"

		local error

		error=$(cargo install taplo-cli --locked --features lsp 2>&1) || {
			echo -e "\n\t${RED}TOML LSP installation failed:${NO_COLOR} ${error}"
		}
	fi
}

function install_search_and_replace_tool() {
	if ! is_package_installed scooter; then
		echo -e "\n${GREEN}Installing Scooter (search and replace tool)...${NO_COLOR}"

		local error

		error=$(cargo install scooter --locked 2>&1) || {
			echo -e "\n\t${RED}Scooter installation failed:${NO_COLOR} ${error}"
		}
	fi
}

function install_gitui() {
	if ! is_package_installed gitui; then
		echo -e "\n${GREEN}Installing gitui...${NO_COLOR}"

		local error

		if ! is_package_installed cmake; then
			echo -e "\n\t${GREEN}Installing CMake dependency...${NO_COLOR}"

			error=$(sudo $package_manager install -y cmake 2>&1) || {
				echo -e "\n\t${RED}CMake installation failed:${NO_COLOR} ${error}"
			}
		fi

		error=$(cargo install gitui --locked 2>&1) || {
			echo -e "\n\t${RED}gitui installation failed:${NO_COLOR} ${error}"
		}
	fi
}

function install_rust_toolchain() {
	if ! is_package_installed rustup; then
		echo -e "\n${GREEN}Installing Rust toolchain...${NO_COLOR}"

		local error

		error=$(curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y 2>&1) || {
			echo -e "\n\t${RED}Rust toolchain installation failed:${NO_COLOR} ${error}"
		}

		rustup update
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
install_fish_shell
install_helix_editor

echo -e "\n${YELLOW}Post-installation manual steps:${NO_COLOR}${postinstall_manual_steps}"
