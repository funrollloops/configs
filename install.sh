#!/bin/bash

set -e

files=$(find .  -maxdepth 1 -name '.*' -type f  -not -name '*.swp' |
        xargs -n1 readlink -f)

function link {
  local src=$1
  local dest=$2
  echo -ne "installing $src..."
  if [ ! -e "$dest" ]; then
    ln -s "$src" "$dest"
    echo ok
  elif [ "$(readlink -f "$dest")" != "$src" ]; then
    echo "file in the way, remove"
    ls -l "$dest"
  else
    echo already there
  fi
}

function link-all {
  for file in $files; do
    link "$file" "$HOME/$(basename $file)"
  done

  mkdir -p ~/.config/nvim ~/.vim/{autoload,bundle,after/ftplugin/python}
  link ~/.vim/autoload ~/.config/nvim/autoload
  link ~/.vim/bundle ~/.config/nvim/bundle
  link ~/.vim/after ~/.config/nvim/after
  link $(readlink -f ./.vimrc) ~/.config/nvim/init.vim
  link $(readlink -f ./python.vim) ~/.config/nvim/after/ftplugin/python/python.vim
  link $(readlink -f bin) ~/.bin
  echo done
}

function install-packages {
  echo 'installing packages...'
  sudo dnf install python3-dev npm python3-pip git neovim tmux
}

function install-vim-plugins {
  echo 'installing vim plugins...'
  if [ ! -e ~/.vim/autoload/plug.vim ] ; then
    echo 'installing vim-plug'
    (
      mkdir -p ~/.vim/autoload
      cd ~/.vim/autoload
      wget https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    )
    # For clang-complete etc
    nvim +PlugInstall
  else
    echo 'vim-plug already installed'
  fi
}

link-all
install-packages
install-vim-plugins
