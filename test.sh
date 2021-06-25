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
  xcode-select --install
}

# Sudo Magic :)
sudo -v

# Keep-alive: update existing `sudo` time stamp until we have finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

[ ! -d "/Library/Developer/CommandLineTools" ] && installcli

echo "Updating pip"
export PATH="$HOME/Library/Python/3.8/bin:/opt/homebrew/bin:$PATH"
sudo python3 -m pip install --upgrade pip

echo "Installing Ansible"
python3 -m pip install ansible pexpect jmespath

mkdir -p $HOME/tmpgit
git clone https://github.com/tuxpeople/ansible-mac-bootstrap.git $HOME/tmpgit

echo "Setting max open files"
cd $HOME/tmpgit
sudo cp files/system/limit.maxfiles.plist /Library/LaunchDaemons
sudo cp files/system/limit.maxproc.plist /Library/LaunchDaemons
sudo chown root:wheel /Library/LaunchDaemons/limit.maxfiles.plist
sudo chown root:wheel /Library/LaunchDaemons/limit.maxproc.plist
sudo launchctl load -w /Library/LaunchDaemons/limit.maxfiles.plist
sudo launchctl load -w /Library/LaunchDaemons/limit.maxproc.plist

chsh -s /bin/bash

curl -L https://raw.githubusercontent.com/tuxpeople/dotfiles/master/Brewfile > files/Brewfile

ansible-galaxy install -r requirements.yml

ansible-playbook main.yml --ask-become-pass

cd

rm -rf $HOME/tmpgi