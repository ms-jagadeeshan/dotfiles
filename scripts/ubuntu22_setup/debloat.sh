function remove_snap()
{
    sudo snap remove --purge snap-store
    sudo snap remove --purge gnome-3-38-2004
    sudo snap remove --purge gnome-42-2204
    sudo snap remove --purge gtk-common-themes
    sudo snap remove --purge snapd-desktop-integration
    sudo snap remove --purge bare
    sudo snap remove --purge core20
    sudo snap remove --purge snapd
    sudo apt remove --autoremove snapd

    echo '
Package: snapd
Pin: release a=*
Pin-Priority: -10
    ' | sudo tee /etc/apt/preferences.d/nosnap.pref

    sudo apt install --install-suggests gnome-software
}


curl -lO https://github.com/Skyedra/UnspamifyUbuntu/blob/master/fake-ubuntu-advantage-tools/fake-ubuntu-advantage-tools.deb?raw=true
sudo apt install ./fake-ubuntu-advantage-tools.deb
rm fake-ubuntu-advantage-tools.deb
