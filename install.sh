#!/bin/bash

set -e

files=$(find . -maxdepth 1 -name '.*' -type f -not -name '*.swp' \
  -exec readlink -f {} \;)

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
GH_CLI_VERSION=2.14.4

declare -a DEFAULT_COMMANDS
DEFAULT_COMMANDS=(
  link_files
  install_nvim
  install_packages
  install_update_ghcli
  generate_ssh_key  # requires ghcli
  install_vim_plug  # requires nvim
  install_setcpu # requires packages
  configure_mouse  # requires packages (particularly gnome-session)
)

function _run {
  echo "=== $*"
  "$@"
}

function _link {
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

function _have_command {
  for cmd in "$@"; do
    command -v "${cmd}" > /dev/null 2> /dev/null && return 0
  done
  return 1
}

function link_files {
  for file in $files; do
    _link "$file" "$HOME/$(basename "$file")"
  done

  mkdir -p ~/.config/nvim ~/.vim/{autoload,bundle,after/ftplugin/python}
  _link ~/.vim/autoload ~/.config/nvim/autoload
  _link ~/.vim/bundle ~/.config/nvim/bundle
  _link ~/.vim/after ~/.config/nvim/after
  _link "$(readlink -f ./yapf)" ~/.config/yapf/style
  _link "$(readlink -f ./.vimrc)" ~/.config/nvim/init.vim
  _link "$(readlink -f ./python.vim)" ~/.config/nvim/after/ftplugin/python/python.vim
  _link "$(readlink -f bin)" ~/.bin
  echo 'done installing symlinks'
}

function generate_ssh_key {
  if find ~/.ssh -name \*.pub 2> /dev/null | grep -q .; then
    echo 'ssh key exists'
    return 0
  fi
  mkdir -p ~/.ssh
  _run ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)"
  gh ssh-key add ~/.ssh/id_ed25519.pub
}

function sys_pkg_install {
  if _have_command apt; then
    _run sudo apt install -y "$@"
  elif _have_command dnf; then
    local -a PKGS
    for pkg in "$@"; do
      case "${pkg}" in
        clangd) PKGS+=(clang-tools-extra) ;;
        clang-format) PKGS+=(clang-tools-extra) ;;
        shellcheck) PKGS+=(ShellCheck) ;;
        yapf3) PKGS+=(python3-yapf) ;;
        *) PKGS+=("${pkg}") ;;
      esac
    done
    _run sudo dnf install -y "${PKGS[@]}"
  fi
}

function install_packages {
  local -a to_install

  source ~/.bashrc

  function command_package {
    if ! _have_command "$1"; then
      if [[ "$#" -gt 1 ]]; then
        shift
      fi
      to_install+=("$@")
    fi
  }

  for bin in npm ccache clang clangd clang-format lld tmux git tree xclip \
    ipython3 shellcheck direnv curl podman gnome-session diffstat; do
    command_package "${bin}"
  done
  command_package rg ripgrep
  command_package python3 python3
  if ! python3 -m venv --help > /dev/null 2> /dev/null; then
    to_install+=("python3-venv")
  fi
  command_package python python-is-python3
  command_package pip3 python3-pip
  command_package ninja ninja-build
  command_package go golang-go
  command_package ctags universal-ctags
  if ! git gui version > /dev/null; then
    to_install+=(git-gui)
  fi
  if ! _have_command yapf yapf3; then
    to_install+=(yapf3)
  fi
  if ((${#to_install[@]})); then
    sys_pkg_install "${to_install[@]}"
  else
    echo 'system packages already installed'
  fi

  to_install=()
  command_package pyright
  command_package tsc typescript typescript-language-server
  command_package vim-language-server
  if ((${#to_install[@]})); then
    _run sudo -H npm install -g "${to_install[@]}"
  else
    echo 'npm packages already installed'
  fi
}

function install_update_ghcli {
  if _have_command gh; then
    echo "gh cli already installed; will auto-update"
    return
  fi
  mkdir -p download
  (
    cd download
    local ext=err
    if _have_command apt; then
      ext=deb
    elif _have_command dnf; then
      ext=rpm
    fi
    curl -fLO https://github.com/cli/cli/releases/download/v${GH_CLI_VERSION}/gh_${GH_CLI_VERSION}_linux_amd64.${ext}
    sys_pkg_install ./gh_${GH_CLI_VERSION}_linux_amd64.${ext}
  )
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
  _run curl -fL \
    "https://github.com/neovim/neovim/releases/download/v$VERSION/nvim.appimage" \
    -o "${DEST}"
  chmod u+x "${DEST}"
  ln -sf "$(realpath "$DEST")" "${SCRIPT_DIR}/bin/nvim"
  echo "OK"
}

function install_vim_plug {
  if [ -e ~/.vim/autoload/plug.vim ]; then
    echo 'vim-plug already installed, updating'
    _run nvim +PlugUpdate +qa
    return
  fi
  echo 'installing vim-plug'
  (
    mkdir -p ~/.vim/autoload
    cd ~/.vim/autoload
    wget https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  )
  _run nvim +PlugInstall +qa
}

function install_setcpu {
  make -C src set-cpu
  _run sudo chown root src/set-cpu
  _run sudo chmod +s src/set-cpu
  cp "$(readlink -f src/set-cpu)" bin/set-cpu
}

function configure_mouse {
  if _have_command gsettings 2> /dev/null; then
    echo "configuring focus-follows-mouse"
    gsettings set org.gnome.desktop.wm.preferences focus-mode sloppy
    gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll false
    gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
  else
    echo "skipping, no gsettings"
  fi
}

function main {
  for cmd in "$@"; do
    _run "$cmd"
  done
}

if [ "$#" == 0 ]; then
  main "${DEFAULT_COMMANDS[@]}"
else
  main "$@"
fi
