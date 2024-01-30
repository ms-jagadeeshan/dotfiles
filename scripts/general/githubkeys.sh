
pushd ~/.ssh || return
ssh-keygen -t ed25519 -C "jagadeeshanmsj@gmail.com" -f ~/.ssh/githubkey
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/githubkey
xclip -sel c < ~/.ssh/githubkey.pub
popd || return
