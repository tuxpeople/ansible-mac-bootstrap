#!/bin/bash

CWD=`pwd`
cd `dirname "$(realpath $0)"`

curl -L https://raw.githubusercontent.com/tuxpeople/dotfiles/master/Brewfile > files/Brewfile

ansible-galaxy install -r requirements.yml

ansible-playbook main.yml -i inventory -K

cd $CWD
