#!/bin/bash

########################################################
# Script which set up toolchain and CUDA tools for NVIDIA.
# Author: Eldar
# Date: 22.11.2023
########################################################

set -e

sudo apt update && sudo apt upgrade -y
sudo apt install gcc wget
sudo apt install ubuntu-drivers-common
sudo ubuntu-drivers devices
sudo apt install nvidia-driver-535

nvidia-smi

wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update
sudo apt-get -y install cuda-toolkit-12-2
sudo apt-get install -y cuda-drivers

export PATH=/usr/local/cuda-12.2/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda-12.2/lib64\\
            ${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

nvcc -V

curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \\
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \\
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \\
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list \\
  && \\
    sudo apt-get update

sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
sudo nvidia-ctk runtime configure --runtime=containerd
sudo systemctl restart containerd
sudo docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi

sudo reboot now
