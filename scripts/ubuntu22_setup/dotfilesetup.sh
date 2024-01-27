git init --bare $HOME/.mydotfiles 
alias dotfiles='/usr/bin/git --git-dir=$HOME/.mydotfiles/ --work-tree=$HOME'    
dotfiles config status.showUntrackedFiles no

