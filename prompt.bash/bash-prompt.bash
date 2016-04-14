#!/bin/bash
# .bash_profile
BLACK="\e[0;30m"
RED="\e[0;31m"
GREEN="\e[0;32m"
YELLOW="\e[0;33m"
BLUE="\e[0;34m"
CYAN="\e[0;36m"
WHITE="\e[1;37m"
MAGENTA="\e[0;"
RETURN="\e[m"
BOLD="tput bold"
REV="\e[m"


function parse_git_branch {
    ref=$(git symbolic-ref HEAD 2> /dev/null) || return;
    echo "("${ref#refs/heads/}") "
}
PS1="$CYAN\$(__docker_machine_ps1)$WHITE[\u] \w$GREEN \$(parse_git_branch)$RETURN\\$ ";

alias ll='ls -a -l -G'
alias ls='ls -G'
alias _go='cd ~/Projects/_go'
alias _projects='cd ~/Projects'

if [ `uname -a|awk '{ print $1}'` == 'Darwin' ] ; then
# Ref: http://blog.lyhdev.com/2015/03/mac-os-x-command-hacks-markdown-rtf.html
    alias md2rtf='pbpaste | pandoc -f markdown -t html | textutil -stdin -format html -convert rtf -stdout -inputencoding UTF-8 -encoding UTF-8 | pbcopy'
fi;

export HOMEBREW_GITHUB_API_TOKEN=a6176d3671d684c2508e766fe11028d3776037f3
