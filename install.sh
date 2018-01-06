#!/bin/bash
VIMHOME=~/.vim

warn() {
    echo "$1" >&2
}

die() {
    warn "$1"
    exit 1
}

[ -e "$HOME/.vimrc" ] && die "~/.vimrc already exists."

git submodule update --init

cd ~
ln -s .vim/vimrc .vimrc
ln -s .vim/tmux.conf .tmux.conf
ln -s .vim/terraformrc .terraformrc

PROFILE="$HOME/.bash_profile"

for f in bash-prompt.bash docker-prompt.bash docker-compose-prompt.bash docker-machine-prompt.bash
do
    if grep -qe ${f%.bash} $PROFILE; then
        echo "SKIP... since $f has linked to $PROFILE.";
    else
        echo "source ~/.vim/prompt.bash/$f" >> $PROFILE
        echo "Injected $f into your $PROFILE";
    fi
done

if [ `uname -a|awk '{ print $1}'` == "Darwin" ] ; then
    if grep -qe "git-completion" $PROFILE; then
        echo "SKIP... since git-completion.bash(Apple XCode) has linked to $PROFILE.";
    else
        brew install bash-completion
        echo 'source /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-completion.bash' >> $PROFILE
        echo "Injected git-completion.bash(Apple XCode) into your $PROFILE";
    fi
fi;
mkdir -p ~/.ssh/config.d/

echo "Your VIM configuration has been installed."

read -p '==> Do you want to install homebrew? (y/n)' install_brew

if [ $install_brew == "y" ]; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

    read -p '==> Install VIM/jq from homebrew? (y/n)' install_vim_jq
    if [ $install_vim_jq == "y" ]; then
        /usr/local/bin/brew install vim jq
    fi
fi
