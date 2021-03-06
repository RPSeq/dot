#!/bin/bash

#------------------------------------------------------------------------------
# File:   $HOME/start.sh
# Author: Ryan Smith  <ryan.smith.p@gmail.com>
#------------------------------------------------------------------------------

set -euxo pipefail

# configure git
ginit() {
    git config --global user.name "RPSeq"
    git config --global user.email "ryan.smith.p@gmail.com"
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/key_name.pem
}

# add sources
sources() {
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
    echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
    echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" | sudo tee /etc/apt/sources.list.d/atom.list
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
}

# add apt keys
keys() {
    sudo wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
    sudo wget -qO - https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    sudo wget -qO - https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -
    sudo wget -qO - https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
}

# update sources and install
install() {
    sudo apt-get -y update
    sudo apt-get -y install \
        vim-gnome \
        sublime-text \
        libpam-fprintd \
        fprint-demo \
        editorconfig \
        curl \
        ca-certificates \
        gnupg2 \
        software-properties-common \
        htop \
        docker-ce \
        python \
        python-pip \
        xclip \
        tmux \
        firmware-iwlwifi \
	    firmware-linux-nonfree \
        plymouth \
        plymouth-themes \
        atom \
        code \
        tlp \
        tlp-rdw

    set +e
    sudo modprobe -r iwlwifi && sudo modprobe iwlwifi
    set -e
}

wallpaper() {
    sudo mkdir -p /usr/share/backgrounds/debian
    sudo chown rsmith -R /usr/share/backgrounds/debian
    ln -sf "$(pwd)"/images /usr/share/backgrounds/debian
}

# manual installs
firefox() {
    sudo curl -fsSL -o firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US"
    sudo tar -C /opt -xvf firefox.tar.bz2
    sudo rm -rf firefox.tar.bz2
    sudo ln -sf "$(pwd)"/firefox/firefox.desktop /usr/share/applications/firefox.desktop
    sudo apt-get -y remove firefox-esr
}

chrome() {
    sudo curl -fsSL -o chrome.deb "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
    sudo dpkg --force-all -i chrome.deb
    sudo apt-get install -yf
    sudo rm -rf chrome.deb
    sudo apt-get remove chromium
}

vundle() {
    set +e
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    set -e
}

config() {
    ln -sf /home/rsmith/dot/editor/.editorconfig ~/.editorconfig
    ln -sf /home/rsmith/dot/vim/.vimrc ~/.vimrc
    ln -sf /home/rsmith/dot/bash/.bashrc ~/.bashrc
    ln -sf /home/rsmith/dot/config/gtk-3.0/settings.ini ~/.config/gtk-3.0/settings.ini
    sudo sed -ie 's/^Exec=gnome-terminal/Exec=gnome-terminal --maximize/g' /usr/share/applications/org.gnome.Terminal.desktop
}

plymouth() {
    sudo cp -f /home/rsmith/dot/initramfs-tools/modules /etc/initramfs-tools/modules
    sudo cp -f /home/rsmith/dot/grub/grub /etc/default/grub
    sudo update-grub2
    git clone https://gitlab.com/maurom/deb10.git
    cd deb10
    sudo make install
    cd ..
    sudo rm -rf deb10
    sudo plymouth-set-default-theme -R deb10
}

discord()  {
    sudo curl -fsSL -o discord.deb "https://discordapp.com/api/download?platform=linux&format=deb"
    sudo dpkg --force-all -i discord.deb
    sudo apt-get install -yf
    sudo rm -rf discord.deb
}

steam() {
    sudo dpkg --add-architecture i386
    sudo apt-get update
    sudo apt-get install steam
}

slack() {
    sudo curl -fsSL -o slack.deb "https://downloads.slack-edge.com/linux_releases/slack-desktop-3.3.1-amd64.deb"
    sudo dpkg --force-all -i slack.deb
    sudo rm -rf slack.deb
}

keybase() {
    sudo curl -fsSL -o keybase_amd64.deb "https://prerelease.keybase.io/keybase_amd64.deb"
    sudo dpkg --force-all -i keybase_amd64.deb
    sudo apt-get install -yf
    sudo rm -rf keybase_amd64.deb
    run_keybase
}

rem() {
    sudo apt-get autoremove -y
}

ginit
sources
keys
install
wallpaper
firefox
chrome
vundle
config
plymouth
discord
steam
slack
keybase
rem
