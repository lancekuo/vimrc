#!/bin/sh
VIMHOME=~/.vim

warn() {
    echo "$1" >&2
}

die() {
    warn "$1"
    exit 1
}

[ -e "~/.vimrc" ] && die "~/.vimrc already exists."

git submodule update --init

cd ~
ln -s .vim/vimrc .vimrc
ln -s .vim/tmux.conf .tmux.conf

echo 'source ~/.vim/prompt.bash/docker-machine-prompt.bash' > ~/.bash_profile
echo 'source ~/.vim/prompt.bash/docker-compose-prompt.bash' >> ~/.bash_profile
echo 'source ~/.vim/prompt.bash/bash-prompt.bash' >> ~/.bash_profile

echo "Your VIM configuration has been installed."
