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
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bash_profile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi;

read -p '==> Install VIM/jq from homebrew? (y/n)' install_vim_jq
if [ $install_vim_jq == "y" ]; then
    # brew install python3
    # pip3 install neovim ujson pynvim # Make sure we having homebrew shellenv injected or we are going to mix up diff py version here
    # ^^ comment out due to out-of-date
    # terraform@1.5.* stay with Mozilla Public License
    brew install vim jq yq fzf tmuxinator git bash-completion go terraform terraform-ls bat
    $(brew --prefix)/opt/fzf/install --no-zsh --no-fish
    echo "[[ -r \"\$(brew --prefix)/etc/profile.d/bash_completion.sh\" ]] && . \"\$(brew --prefix)/etc/profile.d/bash_completion.sh\"" >> ~/.bash_profile

    terraform -install-autocomplete
fi

read -p '==> Install awscli and terraform tools from homebrew? (y/n)' install_awscli
if [ $install_awscli == "y" ]; then
    brew install awscli iam-policy-json-to-terraform miniconda
fi

read -p '==> Install kubectl tools from homebrew? (y/n)' install_k8s
if [ $install_k8s == "y" ]; then
    brew install kubernetes-cli kubectx helm k9s
    helm plugin install https://github.com/databus23/helm-diff --version v3.8.1
    helm plugin install https://github.com/jkroepke/helm-secrets --version v4.5.1
fi

read -p '==> Install google cloud sdk from curl? (y/n)' install_gcloud
if [ $install_gcloud == "y" ]; then
    brew install google-cloud-sdk
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
# [ -e "$HOME/.vimrc" ] && die "~/.vimrc already exists."

git submodule update --init
git config --global init.defaultBranch main
git config --global --add merge.tool vimdiff
git config --global --add merge.conflictstyle diff3
git config --global --add mergetool.prompt false
git config --global --add user.name "Lance Kuo"
git config --global --add user.email lancekuo@gmail.com
git config --global --add commit.gpgsign true
# Aim to solve the problem from `go dep` issue
git config --global --add url.git@github.com:.insteadOf https://github.com/
git config --global alias.oldest-ancestor '!bash -c '\''diff --old-line-format='' --new-line-format='' <(git rev-list --first-parent "${1:-master}") <(git rev-list --first-parent "${2:-HEAD}") | head -1'\'' -'
git config --global alias.branchdiff '!bash -c "git diff `git oldest-ancestor`.."'
git config --global alias.branchlog '!bash -c "git log `git oldest-ancestor`.."'
git config --global alias.permission-resetb '!git diff -p --no-ext-diff --no-color --diff-filter=d | grep -E "^(diff|old mode|new mode)" | sed -e "s/^old/NEW/;s/^new/old/;s/^NEW/new/" | git apply'
git config --global alias.glog 'log --oneline --graph --all --decorate'

ln -s $PWD $HOME/.vim
ln -s $HOME/.vim/vimrc $HOME/.vimrc
ln -s $HOME/.vim/tmux.conf $HOME/.tmux.conf
ln -s $HOME/.vim/terraformrc $HOME/.terraformrc

for f in bash-prompt.bash
do
    if grep -qe ${f%.bash} $PROFILE; then
        echo "SKIP... since $f has linked to $PROFILE.";
    else
        echo "source ~/.vim/prompt.bash/$f" >> $PROFILE
        echo "Injected $f into your $PROFILE";
    fi
done

cat << EOF >> $HOME/.bash_profile
if type brew &>/dev/null
then
  HOMEBREW_PREFIX="$(brew --prefix)"
  if [[ -r "\${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]
  then
    source "\${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
  else
    for COMPLETION in "\${HOMEBREW_PREFIX}/etc/bash_completion.d/"*
    do
      [[ -r "\${COMPLETION}" ]] && source "\${COMPLETION}"
    done
  fi
fi
EOF

if [ `uname -a|awk '{ print $1}'` == "Darwin" ] ; then
    brew install git && brew link --overwrite git
fi;
mkdir -p $HOME/.ssh/config.d/

[ ! -e "~/.ssh/config.d/default" ] && echo -e "host *\n  ControlMaster auto\n  ControlPath ~/.ssh/ssh_mux_%h_%p_%r\n" > ~/.ssh/config.d/default

echo "Your VIM configuration has been installed."

# Setup completion for alias
echo 'complete -o default -o nospace -F __start_kubectl k' >> $PROFILE
echo 'complete -F _kube_contexts ktx' >> $PROFILE
