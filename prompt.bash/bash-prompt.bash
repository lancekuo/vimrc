#!/bin/bash
# .bash_profile
BLACK="\[\e[0;30m\]"
BLUE="\[\e[0;34m\]"
BOLD="tput bold"
BYELLOW="\[\e[1;33m\]"
CYAN="\[\e[0;36m\]"
GREEN="\[\e[0;32m\]"
GREEN_NO_ESC="\e[0;32m"
IBLACK="\[\e[0;90m\]"
MAGENTA="\[\e[0;38m\]"
PS_CLEAR="\[\e[m\]"
RED="\[\e[0;31m\]"
RED_NO_ESC="\e[0;31m"
RETURN="\[\e[m\]"
WHITE="\[\e[1;37m\]"
YELLOW="\[\e[0;33m\]"


function parse_git_branch {
    ref=$(git symbolic-ref --short HEAD 2> /dev/null) || return
    printf "(${ref#refs/heads/})"
}

function parse_git_dirty {
    git status 2 > /dev/null 2>&1 || return;
    if [[ -z $(git status --porcelain) ]]
    then
        printf $GREEN_NO_ESC
    else
        printf $RED_NO_ESC
    fi
}
function parse_terraform_workspace {
    [ -f .terraform/environment ] || return
    ref=$(cat .terraform/environment)
    printf "[${ref}]"
}
PS1="\[\$(parse_git_dirty)\]\$(parse_git_branch)${CYAN}\$(parse_terraform_workspace) ${IBLACK}\w ${PS_CLEAR}\$ ";

if [ `uname -a|awk '{ print $1}'` == 'Darwin' ] ; then
# Ref: http://blog.lyhdev.com/2015/03/mac-os-x-command-hacks-markdown-rtf.html
    alias md2rtf='pbpaste | pandoc -f markdown -t html | textutil -stdin -format html -convert rtf -stdout -inputencoding UTF-8 -encoding UTF-8 | pbcopy'
    if [ -f $(brew --prefix)/etc/bash_completion ]; then
        . $(brew --prefix)/etc/bash_completion
    fi
fi

alias ll='ls -a -l -G'
alias ls='ls -G'
alias _projects='cd ~/Projects'
alias rebuild-ssh-config='cat ~/.ssh/config.d/* > ~/.ssh/config'
alias reload-env='. ~/.bash_profile'
alias k='kubectl'
alias ktx='kubectx'

export RUBYOPT='--disable-did_you_mean' # Fixed tmuxinator ruby warning msg
export EDITOR='vim' # Value for tmuxinator
export DISABLE_AUTO_TITLE=true # fixed mess up window title in terminal with tmuxinator

# AWS MFA script alias
# $ mfa code
setToken() {
    ~/.vim/opt/bin/mfa.sh $1 $2
    source ~/.token_file
    echo "Your creds have been set in your env."
}
alias mfa=setToken
if [ -f "$HOME/.token_file" ]; then . "$HOME/.token_file"; fi
