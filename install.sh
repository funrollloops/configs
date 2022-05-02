#!/bin/bash

set -e

files=$(find . -maxdepth 1 -name '.*' -type f -not -name '*.swp' \
  -exec readlink -f {} \;)

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")

function run {
  echo "=== $*"
  "$@"
}

function link {
  local src=$1
  local dest=$2
  echo -ne "installing $src..."
  if [ ! -e "$dest" ]; then
    mkdir -p "$(dirname "${dest}")"
    ln -s "$src" "$dest"
    echo ok
  elif [ "$(readlink -f "$dest")" != "$src" ]; then
    echo -e "\033[0;31mfile in the way, remove\033[0m"
    ls -l "$dest"
    return 1
  else
    echo already there
  fi
}

function generate_ssh_key {
  if find ~/.ssh -name *.pub 2>/dev/null | grep -q .; then
    echo 'ssh key exists'
    return 0
  fi
  mkdir -p ~/.ssh
  run ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)"
}

function install_packages {
  local -a to_install

  source ~/.bashrc

  function command_package {
    if ! command -v "$1" > /dev/null; then
      if [[ "$#" -gt 1 ]]; then
        shift
      fi
      to_install+=("$@")
    fi
  }

  for bin in npm ccache clang clangd clang-format lld tmux git nvim tree xclip \
    ipython3 shellcheck yapf3 direnv curl podman gnome-session diffstat; do
    command_package "${bin}"
  done
  command_package rg ripgrep
  command_package python3 python3
  if ! python3 -m venv --help >/dev/null 2>/dev/null; then
    to_install+=("python3-venv")
  fi
  command_package python python-is-python3
  command_package pip3 python3-pip
  command_package ninja ninja-build
  command_package go golang-go
  command_package ctags universal-ctags
  if ! dpkg-query -s git-gui > /dev/null; then
    to_install+=(git-gui)
  fi

  if ((${#to_install[@]})); then
    run sudo apt install -y "${to_install[@]}"
  else
    echo 'apt packages already installed'
  fi

  to_install=()
  command_package pyright
  command_package tsc typescript typescript-language-server
  command_package vim-language-server
  if ((${#to_install[@]})); then
    run sudo -H npm install -g "${to_install[@]}"
  else
    echo 'npm packages already installed'
  fi

  if ! command -v gh >/dev/null; then
    mkdir -p download
    (
      cd download
      curl -fLO https://github.com/cli/cli/releases/download/v2.8.0/gh_2.8.0_linux_amd64.deb
      sudo dpkg -i gh_2.8.0_linux_amd64.deb
    )
  fi
}

function install_nvim {
  local VERSION=0.7.0
  local DEST="${SCRIPT_DIR}/bin/nvim-$VERSION"
  if [ -e "${DEST}" ]; then
    echo "nvim $VERSION already installed"
    return
  else
    echo "installing nvim $VERSION..."
  fi
  run curl -fL \
    "https://github.com/neovim/neovim/releases/download/v$VERSION/nvim.appimage" \
    -o "${DEST}"
  chmod u+x "${DEST}"
  ln -sf "$(realpath "$DEST")" "${SCRIPT_DIR}/bin/nvim"
  echo "OK"
}

function install_vim_plug {
  if [ -e ~/.vim/autoload/plug.vim ]; then
    echo 'vim-plug already installed, updating'
    run nvim +PlugUpdate
    return
  fi
  echo 'installing vim-plug'
  (
    mkdir -p ~/.vim/autoload
    cd ~/.vim/autoload
    wget https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  )
  run nvim +PlugInstall
}

for file in $files; do
  link "$file" "$HOME/$(basename "$file")"
done

mkdir -p ~/.config/nvim ~/.vim/{autoload,bundle,after/ftplugin/python}
link ~/.vim/autoload ~/.config/nvim/autoload
link ~/.vim/bundle ~/.config/nvim/bundle
link ~/.vim/after ~/.config/nvim/after
link "$(readlink -f ./yapf)" ~/.config/yapf/style
link "$(readlink -f ./.vimrc)" ~/.config/nvim/init.vim
link "$(readlink -f ./python.vim)" ~/.config/nvim/after/ftplugin/python/python.vim
link "$(readlink -f bin)" ~/.bin
echo 'done installing symlinks'

generate_ssh_key
install_nvim
install_packages
install_vim_plug
