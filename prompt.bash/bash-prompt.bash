#!/bin/bash
# .bash_profile
BLACK="\e[0;30m"
RED="\e[0;31m"
GREEN="\e[0;32m"
YELLOW="\e[0;33m"
BLUE="\e[0;34m"
CYAN="\e[0;36m"
WHITE="\e[1;37m"
MAGENTA="\e[0;38m"
RETURN="\e[m"
BOLD="tput bold"
REV="\e[m"


function parse_git_branch {
    ref=$(git symbolic-ref HEAD 2> /dev/null) || return
    printf " (${ref#refs/heads/}) "
}

function parse_git_dirty {
    git status 2 > /dev/null 2>&1 || return;
    if git status |grep -q "nothing to commit"
    then
        printf $GREEN
    else
        printf $RED
    fi
}
function parse_terraform_workspace {
    [ -f .terraform/environment ] || return
    ref=$(cat .terraform/environment)
    printf "[${ref}] "
}
PS1="$CYAN\$(__docker_machine_ps1)$WHITE[\u] \w\$(parse_git_dirty)\$(parse_git_branch)$CYAN\$(parse_terraform_workspace)$RETURN\\$ ";

if [ `uname -a|awk '{ print $1}'` == 'Darwin' ] ; then
# Ref: http://blog.lyhdev.com/2015/03/mac-os-x-command-hacks-markdown-rtf.html
    alias md2rtf='pbpaste | pandoc -f markdown -t html | textutil -stdin -format html -convert rtf -stdout -inputencoding UTF-8 -encoding UTF-8 | pbcopy'
    if [ -f $(brew --prefix)/etc/bash_completion ]; then
        . $(brew --prefix)/etc/bash_completion
    fi
fi



export HOMEBREW_GITHUB_API_TOKEN=a6176d3671d684c2508e766fe11028d3776037f3

alias ll='ls -a -l -G'
alias ls='ls -G'
alias _projects='cd ~/Projects'
alias update-ssh-config='cat ~/.ssh/config.d/* > ~/.ssh/config'
