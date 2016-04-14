#!/bin/bash
if [ `uname -a|awk '{ print $1}'` == "Darwin" ] ; then
    defaultgopath="$HOME/Projects/_go"
else
    defaultgopath="/vagrant"
fi;
echo "Please enter your GOPATH: [default: $defaultgopath]"
read gopath
if [ "$gopath" == "" ]; then
    gopath=$defaultgopath;
fi;

if [ `uname -a|awk '{ print $1}'` == "Darwin" ] ; then
    echo -e "export GOPATH=$gopath\nexport PATH=$PATH:\$GOPATH/bin" >> ~/.bash_profile
    source ~/.bash_profile
else
    echo -e "export GOPATH=$gopath\nexport PATH=$PATH:\$GOPATH/bin" > /etc/profile.d/golang.sh
    source /etc/profile
fi;

go get -u github.com/jstemmer/gotags
go get -u github.com/nsf/gocode
go get -u github.com/rogpeppe/godef
if [ `go env GOOS` == "darwin" ]; then
# https://github.com/leoliu/ggtags/wiki/Install-Global-with-support-for-exuberant-ctags
    brew install -y ctags
    brew link ctags
    brew install global --with-exuberant-ctags
    brew install -y the_silver_searcher
else
    apt-get install -y ctags
    wget https://launchpad.net/~pgolm/+archive/ubuntu/the-silver-searcher/+files/the-silver-searcher_0.15-1_amd64.deb
    dpkg -i the-silver-searcher_0.15-1_amd64.deb
# rpm -ivh http://swiftsignal.com/packages/centos/6/x86_64/the-silver-searcher-0.13.1-1.el6.x86_64.rpm
fi;
