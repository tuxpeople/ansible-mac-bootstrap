#!/bin/bash

CWD=`pwd`
cd `dirname "$(realpath $0)"`

ansible-playbook main.yml -i inventory -K

cd $CWD