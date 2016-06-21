files=$(find .  -maxdepth 1 -name '.*' -type f  -not -name '*.swp' |
        xargs -n1 readlink -f)

for file in $files; do
  dest="$HOME/$(basename $file)"
  echo -ne "installing $file..."
  if [ ! -e "$dest" ]; then
    ln -s "$file" "$dest"
    echo ok
  elif [ "$(readlink -f "$dest")" != "$file" ]; then
    echo "file in the way, remove"
    ls -l "$dest"
  else
    echo already there
  fi
done

echo done
