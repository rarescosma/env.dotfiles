set PATH ~/bin ~/npm/bin ~/.cargo/bin $PATH
set EDITOR nvim
set VISUAL nvim
set fish_greeting ""

# Kill all running containers.
alias dockerkill='docker kill (docker ps -q)'

# Delete all docker images and containers.
alias dockernuke='docker rm (docker ps -a -q); docker rmi -f (docker images -q)'

# Other git aliases are in git config
alias g="git"
alias l="ls -lah"

# Some software still uses vimdiff
alias vimdiff="nvim -d"

# Local config.
if [ -f ~/.local.fish ]
  . ~/.local.fish
end
