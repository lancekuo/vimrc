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

if [ `uname -a|awk '{ print $1}'` == "Darwin" ] ; then
    echo 'source /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-completion.bash' >> ~/.bash_profile
    brew install bash-completion
    brew tap homebrew/completions
fi;
mkdir -p ~/.ssh/config.d/
echo "Your VIM configuration has been installed."
