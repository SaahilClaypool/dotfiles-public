#! /bin/sh
ln -sf $HOME/dotfiles-public/.zshrc $HOME/.zshrc
ln -sf $HOME/dotfiles-public/.tmux.conf $HOME/.tmux.conf

mkdir -p ~/.config/nvim

ln -sf $HOME/dotfiles-public/init.nvim $HOME/.config/nvim/init.vim

cp $HOME/dotfiles-public/.gitconfig ~/.gitconfig
ln -sf  $HOME/dotfiles-public/gitignore_global ~/.gitignore