#!/bin/bash

echo "Are you logged into Mac Appstore?"
read -p "Press enter to continue"

echo "Sudo magic"
# Sudo Magic :)
sudo -v

# Keep-alive: update existing `sudo` time stamp until we have finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "Cloning Repo"
mkdir -p /tmp/git
git clone https://github.com/tuxpeople/ansible-mac-bootstrap.git /tmp/git

echo "Installing Ansible"
pip install --requirement /tmp/git/requirements.txt

echo "Installing Ansible requirements"
ansible-galaxy install -r requirements.yml

echo "Setting max open files"
cd /tmp/git
sudo cp files/system/limit.maxfiles.plist /Library/LaunchDaemons
sudo cp files/system/limit.maxproc.plist /Library/LaunchDaemons
sudo chown root:wheel /Library/LaunchDaemons/limit.maxfiles.plist
sudo chown root:wheel /Library/LaunchDaemons/limit.maxproc.plist
sudo launchctl load -w /Library/LaunchDaemons/limit.maxfiles.plist
sudo launchctl load -w /Library/LaunchDaemons/limit.maxproc.plist

echo "Getting Brewfile"
if [[ $(hostname) == ws* ]]; then
  curl -L https://raw.githubusercontent.com/tuxpeople/dotfiles/master/machine/business/Brewfile > files/Brewfile
else
  curl -L https://raw.githubusercontent.com/tuxpeople/dotfiles/master/machine/private/Brewfile > files/Brewfile
fi

echo "Starting Ansible run"
ansible-playbook main.yml -i inventory -K