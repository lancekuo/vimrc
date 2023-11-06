#!/bin/bash
# Removed obslete code for seting up go env because go has default GOPATH since 1.8(7?)
if [ `uname -a|awk '{ print $1}'` == "Darwin" ] ; then
    substring=$(go env GOPATH)

    if [[ $PATH == *"$substring"* ]]; then
        echo "Substring '$substring' found in the \$PATH. Skipping profile updates..."
    else
        echo "Substring '$substring' not found in the \$PATH."
        echo -e "export PATH=$PATH:$HOME/bin:`go env GOPATH`/bin" >> $HOME/.bash_profile
    fi
    source ~/.bash_profile
else
    echo -e "export PATH=$PATH:$HOME/bin:`go env GOPATH`/bin" > /etc/profile.d/golang.sh
    source /etc/profile
fi;

if [ `go env GOOS` == "darwin" ]; then
    # ctags as a backup for now, we are using coc list to get tag
    brew install universal-ctags
    # brew install global --with-exuberant-ctags
    # brew install the_silver_searcher
else
    apt-get install -y ctags
    wget https://launchpad.net/~pgolm/+archive/ubuntu/the-silver-searcher/+files/the-silver-searcher_0.15-1_amd64.deb
    dpkg -i the-silver-searcher_0.15-1_amd64.deb
# rpm -ivh http://swiftsignal.com/packages/centos/6/x86_64/the-silver-searcher-0.13.1-1.el6.x86_64.rpm
fi;
# Install COC plugin
vim -c "CocInstall coc-snippets coc-pairs coc-lightbulb coc-html coc-fzf-preview coc-explorer coc-go coc-pyright coc-sh coc-docker" -c "qa"

# Install language server
brew install hashicorp/tap/terraform-ls
