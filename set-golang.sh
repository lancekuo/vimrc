#!/bin/bash
echo "Please enter your GOPATH: [default: /vagrant]"
read gopath
if [ "$gopath" == "" ]; then
    gopath="/vagrant";
fi;
echo -e "export GOPATH=$gopath\nexport PATH=$PATH:\$GOPATH/bin" > /etc/profile.d/golang.sh
source /etc/profile

go get -u github.com/jstemmer/gotags
apt-get install -y ctags
