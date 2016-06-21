#!/bin/bash

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

for file in $files; do
  link "$file" "$HOME/$(basename $file)"
done

mkdir -p ~/.config/nvim ~/.vim/{autoload,bundle}
link ~/.vim/autoload ~/.config/nvim/autoload
link ~/.vim/bundle ~/.config/nvim/bundle
link $(readlink -f ./.vimrc) ~/.config/nvim/init.vim

echo done
