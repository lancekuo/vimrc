#!/bin/sh
VIMHOME=~/.vim

warn() {
    echo "$1" >&2
}

die() {
    warn "$1"
    exit 1
}

[ -e "$VIMHOME/vimrc" ] && die "$VIMHOME/vimrc already exists."
[ -e "~/.vim" ] && die "~/.vim already exists."
[ -e "~/.vimrc" ] && die "~/.vimrc already exists."

git clone ssh://git@gitlab.trendnet.org:222/environment/vim.git "$VIMHOME"
cd "$VIMHOME"
git submodule update --init

cd ~
ln -s .vim/vimrc .vimrc
ln -s .vim/tmux.conf .tmux.conf

echo "Your VIM configuration has been installed."
