#!/bin/bash

########################################################
# Script which set up linux server after installed.
# Author: Eldar
# Date: 22.11.2023
########################################################

set -e

sudo apt update && sudo apt upgrade -y
sudo apt install gcc wget htop zsh ufw build-essential net-tools wireless-tools network-manager -y
sudo ufw allow ssh
sudo ufw enable
sudo ufw status
sudo cat /etc/netplan/00-installer-config-wifi.yaml

#systemctl start NetworkManager.service
#systemctl status NetworkManager.service
#systemctl enable NetworkManager.service

chsh -s $(which zsh)

sudo apt autoremove
sudo apt autoclean
sudo apt clean