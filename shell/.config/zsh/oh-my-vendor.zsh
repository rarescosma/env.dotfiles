plugins+=(evalcache gitalias archlinux docker git kubectl kube-ps1 zsh-autosuggestions)
if test -d "$ZSH/custom/plugins/nix-zsh-completions"; then
    plugins+=(nix-zsh-completions)
fi

source "$ZSH/oh-my-zsh.sh"
source "$_VENDOR/z/z.sh"
source "$_VENDOR/fz/fz.sh"
