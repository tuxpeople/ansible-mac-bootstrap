#!/bin/bash

function installcli() {
  # https://gist.github.com/ChristopherA/a598762c3967a1f77e9ecb96b902b5db
  echo "Update MacOS & Install Command Line Interface. If this fails, do it manually."
  sudo /usr/sbin/softwareupdate -l
  touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  sudo /usr/sbin/softwareupdate -ia
  rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  echo "Sleep 20"
  sleep 20
}

# Sudo Magic :)
sudo -v

# Keep-alive: update existing `sudo` time stamp until we have finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

[ ! -d "/Library/Developer/CommandLineTools" ] && installcli

echo "Installing pip"
sudo easy_install -U pip

echo "Ansible"
sudo pip install ansible --upgrade

mkdir -p /tmp/git
git clone https://github.com/tuxpeople/ansible-mac-bootstrap.git /tmp/git

echo "Bootstraping machine"
cd /tmp/git
ansible-galaxy install -r requirements.yml
ansible-playbook main.yml -i inventory -K

rm -rf /tmp/git