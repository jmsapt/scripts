#!/bin/bash

function sync {
  if [ ! -f ~/.config/.templates ]; then
    echo "ERROR: '~/.config/.templates' file is missing"
    exit 1
  fi

  mkdir -p ~/.cache/templates/

  readarray -t dir <<<$(cat ~/.config/.templates)
  # Clone sources
  for src in $dir; do
    cd ~/.cache/templates/
    git clone $src &>/dev/null
  done

  for x in $(basename *); do
    cd $x
    git pull &>/dev/null
    cd ..
  done
}

function list {
  cd ~/.cache/templates/
  for repo in $(basename *); do
    cd $repo
    for t in ./*; do echo "$(basename $t)"; done
    cd ..
  done
}

function copy {
  function err {
    echo "ERR: template '${1}' is missing"
    echo "Hint: try '--sync' or '-s'"
    exit 1
  }

  if [ ! -d ~/.cache/templates ]; then err; fi
  cd ~/.cache/templates/
  dir=$(find -name $1)
  if [ -z "$dir" ]; then err; fi

  cp -r ./$dir/* $2
}

sync_flag=false
list_flag=false
dir=$(pwd)

while getopts 'd:sl' flag; do
  case "${flag}" in
  s) sync_flag=true ;;
  l) list_flag=true ;;
  esac
done

if [ $sync_flag == true ]; then sync; fi
if [ $list_flag == true ]; then list; fi

nth="${@: -1}"
if [ ! -z "$nth" ] && [ "$nth" != '-s' ] && [ "$nth" != '-l' ] && [ "$nth" != '-d' ]; then
  copy $nth $dir
fi
