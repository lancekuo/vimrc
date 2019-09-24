#!/bin/bash
VIMHOME=~/.vim
PROFILE="$HOME/.bash_profile"

warn() {
    echo "$1" >&2
}

die() {
    warn "$1"
    exit 1
}


read -p '==> Do you want to install homebrew? (y/n)' install_brew

if [ $install_brew == "y" ]; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

    read -p '==> Install python3/VIM/jq from homebrew? (y/n)' install_vim_jq
    if [ $install_vim_jq == "y" ]; then
        /usr/local/bin/brew install python3
        /usr/local/bin/pip3 install neovim ujson
        /usr/local/bin/brew install vim
        /usr/local/bin/brew install jq
    fi

    read -p '==> Setup/update Github Token for homebrew? (y/n)' token_for_homebrew
    if [ $token_for_homebrew == "y" ]; then
        read -p '==>==> Paste your token: ' token
        if grep -qe "HOMEBREW_GITHUB_API_TOKEN" $PROFILE; then
            /usr/bin/sed -i "" '/HOMEBREW_GITHUB_API_TOKEN/d' $PROFILE
            echo "export HOMEBREW_GITHUB_API_TOKEN=$token" >> $PROFILE
            echo "Updated the token for Homebrew into your $PROFILE";
        else
            echo "export HOMEBREW_GITHUB_API_TOKEN=$token" >> $PROFILE
            echo "Added the token for Homebrew into your $PROFILE";
        fi
    fi
fi;
[ -e "$HOME/.vimrc" ] && die "~/.vimrc already exists."

git submodule update --init
git config --global --add merge.tool vimdiff
git config --global --add merge.conflictstyle diff3
git config --global --add mergetool.prompt false
git config --global --add user.name "Lance Kuo"
git config --global --add user.email lancekuo@gmail.com
git config --global --add commit.gpgsign true
git config --global alias.oldest-ancestor '!bash -c '\''diff --old-line-format='' --new-line-format='' <(git rev-list --first-parent "${1:-master}") <(git rev-list --first-parent "${2:-HEAD}") | head -1'\'' -'
git config --global alias.branchdiff '!bash -c "git diff `git oldest-ancestor`.."'
git config --global alias.branchlog '!bash -c "git log `git oldest-ancestor`.."'

cd ~
ln -s .vim/vimrc .vimrc
ln -s .vim/tmux.conf .tmux.conf
ln -s .vim/terraformrc .terraformrc

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
    brew install git bash-completion && brew link --overwrite git
fi;
mkdir -p ~/.ssh/config.d/

[ ! -e "~/.ssh/config.d/default" ] && echo -e "host *\n  ControlMaster auto\n  ControlPath ~/.ssh/ssh_mux_%h_%p_%r\n" > ~/.ssh/config.d/default

echo "Your VIM configuration has been installed."
