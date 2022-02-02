#!/bin/bash
# if [ `uname -a|awk '{ print $1}'` == "Darwin" ] ; then
#     defaultgopath="$HOME/Projects/_go"
# else
#     defaultgopath="/vagrant"
# fi;
# echo "Please enter your GOPATH: [default: $defaultgopath]"
# read gopath
# if [ "$gopath" == "" ]; then
#     gopath=$defaultgopath;
# fi;
# 
# if [ `uname -a|awk '{ print $1}'` == "Darwin" ] ; then
#     echo -e "export GOPATH=$gopath\nexport PATH=$PATH:\$GOPATH/bin" >> ~/.bash_profile
#     source ~/.bash_profile
# else
#     echo -e "export GOPATH=$gopath\nexport PATH=$PATH:\$GOPATH/bin" > /etc/profile.d/golang.sh
#     source /etc/profile
# fi;
# Comment out above because go has default GOPATH since 1.8(7?)
if [ `uname -a|awk '{ print $1}'` == "Darwin" ] ; then
    echo -e "export PATH=$PATH:$HOME/bin:`go env GOPATH`/bin" >> $HOME/.bash_profile
    source ~/.bash_profile
else
    echo -e "export PATH=$PATH:$HOME/bin:`go env GOPATH`/bin" > /etc/profile.d/golang.sh
    source /etc/profile
fi;

if [ `go env GOOS` == "darwin" ]; then
    brew install universal-ctags
    # brew install global --with-exuberant-ctags
    brew install the_silver_searcher
else
    apt-get install -y ctags
    wget https://launchpad.net/~pgolm/+archive/ubuntu/the-silver-searcher/+files/the-silver-searcher_0.15-1_amd64.deb
    dpkg -i the-silver-searcher_0.15-1_amd64.deb
# rpm -ivh http://swiftsignal.com/packages/centos/6/x86_64/the-silver-searcher-0.13.1-1.el6.x86_64.rpm
fi;
vim -c GoInstallBinaries -c qa
