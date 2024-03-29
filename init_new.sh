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

echo "Are you logged into Mac Appstore?"
read -p "Press enter to continue"

echo "Enter the hostname: "  
read myhostname  

echo "Sudo magic"
# Sudo Magic :)
sudo -v

# Keep-alive: update existing `sudo` time stamp until we have finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

if [ ! -f "${HOME}/Library/Mobile Documents/com~apple~CloudDocs/Dateien/Allgemein/bin/add_vault_password" ]; then
  echo "Error: Login to iCloud First!"
  exit 1
fi

[ ! -d "/Library/Developer/CommandLineTools" ] && installcli

echo "Cloning Repo"
mkdir -p /tmp/git || exit 1
git clone https://github.com/tuxpeople/ansible-mac-bootstrap.git /tmp/git || exit 1

echo "Upgrading PIP"
pip3 install --upgrade pip || exit 1

echo "Installing Ansible"
pip3 install --requirement /tmp/git/requirements.txt || exit 1
PATH="/usr/local/bin:$(python3 -m site --user-base)/bin:$PATH"
export PATH

echo "Installing Ansible requirements"
ansible-galaxy install -r /tmp/git/requirements.yml || exit 1

echo "Setting max open files"
cd /tmp/git
sudo cp files/system/limit.maxfiles.plist /Library/LaunchDaemons
sudo cp files/system/limit.maxproc.plist /Library/LaunchDaemons
sudo chown root:wheel /Library/LaunchDaemons/limit.maxfiles.plist
sudo chown root:wheel /Library/LaunchDaemons/limit.maxproc.plist
sudo launchctl load -w /Library/LaunchDaemons/limit.maxfiles.plist
sudo launchctl load -w /Library/LaunchDaemons/limit.maxproc.plist

# echo "Getting Brewfile"
# if [[ $(hostname) == ws* ]]; then
#   curl -sfL https://raw.githubusercontent.com/tuxpeople/dotfiles/master/machine/business/Brewfile > files/Brewfile
# else
#   curl -sfL https://raw.githubusercontent.com/tuxpeople/dotfiles/master/machine/private/Brewfile > files/Brewfile
# fi

echo "Starting Ansible run"
echo "If something went wrong, start this step again with:"
echo "     cd /tmp/git && ansible-playbook main.yml -i inventory -K"
ansible-playbook main.yml -i inventory -K --extra-vars "myhostname=${myhostname}"
