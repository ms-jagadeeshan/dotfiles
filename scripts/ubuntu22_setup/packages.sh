#!/bin/bash

function install_0ad(){
    sudo add-apt-repository ppa:wfg/0ad
    sudo apt-get update
    sudo apt-get install 0ad
}

function install_cloudfare(){
    # Add cloudflare gpg key
    curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
    # Add this repo to your apt repositories
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list
    # Install
    sudo apt-get update && sudo apt-get install cloudflare-warp

}

function install_hotspot()
{
    sudo add-apt-repository ppa:lakinduakash/lwh
    sudo apt install linux-wifi-hotspot
}

function fix_firefox()
{
    sudo add-apt-repository ppa:mozillateam/ppa
    echo '
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001

Package: firefox
Pin: version 1:1snap1-0ubuntu2
Pin-Priority: -1
    ' | sudo tee /etc/apt/preferences.d/mozilla-firefox
    sudo snap remove firefox
    sudo apt install firefox
    echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:jammy";' | sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox


}

function install_docker()
{
    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    # install
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

function install_astronvim()
{
    # Install latest nvim appimage
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    chmod u+x nvim.appimage
    sudo apt install neovim
    sudo install nvim.appimage /usr/local/bin/nvim
    rm nvim.appimage
    sudo ln -s /usr/local/bin/nvim /usr/local/bin/vim

    # Take back up of old nvim config
    mv ~/.config/nvim ~/.config/nvim.bak
    mv ~/.local/share/nvim ~/.local/share/nvim.bak
    mv ~/.local/state/nvim ~/.local/state/nvim.bak
    mv ~/.cache/nvim ~/.cache/nvim.bak

    git clone --depth 1 https://github.com/AstroNvim/AstroNvim ~/.config/nvim

    # Optional requirements
    sudo apt install ripgrep
    # Lazy git
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    rm lazygit.tar.gz lazygit

    sudo apt install gdu

    curl -LO https://github.com/ClementTsang/bottom/releases/download/0.9.6/bottom_0.9.6_amd64.deb
    sudo dpkg -i bottom_0.9.6_amd64.deb
    rm bottom_0.9.6_amd64.deb

    curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Ubuntu.zip
    unzip Ubuntu.zip -d ~/.fonts
    fc-cache -fv
    rm Ubuntu.zip

    sudo apt install python3-venv npm
}

function install_ros()
{
    # Set locale
    sudo apt update && sudo apt install locales
    sudo locale-gen en_US en_US.UTF-8
    sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
    export LANG=en_US.UTF-8

    # Setup sources
    sudo apt install software-properties-common
    sudo add-apt-repository universe

    sudo apt update && sudo apt install curl -y
    sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo "$UBUNTU_CODENAME") main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

    sudo apt update && sudo apt upgrade

    sudo apt install ros-humble-ros-base
    sudo apt install ros-humble-joint-state-publisher
    sudo apt install ros-humble-gz
    sudo apt install ros-humble-navigation2
}

function install_nvidia_container_toolkit()
{
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
        && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
        sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

    sudo apt update
    sudo apt install -y nvidia-container-toolkit
    sudo nvidia-ctk runtime configure --runtime=docker
    sudo systemctl restart docker
}

function install_cuda()
{
    aria2c -x 15 -j15 -s15  https://developer.download.nvidia.com/compute/cuda/12.4.0/local_installers/cuda_12.4.0_550.54.14_linux.run

}

function install_touchegg()
{
    sudo apt-apt-repository ppa:touchegg/stable
    sudo apt update
    sudo apt install touchegg
    sudo apt install gnome-shell-extension-manager

}
