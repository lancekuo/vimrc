#!/bin/bash
if [ `go env GOOS` == "darwin" ]; then
    defaultgopath="$HOME/Projects"
else
    defaultgopath="/vagrant"
fi;
echo "Please enter your GOPATH: [default: $defaultgopath]"
read gopath
if [ "$gopath" == "" ]; then
    gopath=$defaultgopath;
fi;

if [ `go env GOOS` == "darwin" ]; then
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
    brew install -y ctags
else
    apt-get install -y ctags
fi;
