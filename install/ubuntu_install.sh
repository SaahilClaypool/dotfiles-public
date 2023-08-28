#! /bin/sh

set -o pipefail

echo "============ APT INSTALL ============================="
sudo apt update && sudo apt upgrade -y

sudo apt install -y neovim git tmux zsh curl htop python3 python3-pip postgresql-14

echo "============ INSTALLING BREW ============================="
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"


[ -x /home/linuxbrew/.linuxbrew/bin/brew ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

brew install fzf
brew install zoxide
brew install rg
brew install jq

python3 -m pip install pgcli

echo "============ SETTING CONFIG ============================="

chsh -y /usr/bin/zsh

