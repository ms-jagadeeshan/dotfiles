#!/bin/bash
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
