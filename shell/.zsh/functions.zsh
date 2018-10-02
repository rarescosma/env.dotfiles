alias sudo='sudo -E '

# -- Fs ------------------------------------------------------------------------
unalias z
alias ...='cd ../../'
alias ....='cd ../../../'
alias rg="rg --hidden --follow --smart-case"
alias locate='locate -i'

if (( $+commands[rmtrash] )); then
  alias rm='rmtrash -rf'
fi
alias rm!='\rm -rf'

if (( $+commands[exa] )); then
  alias l="exa -lhg --git --group-directories-first"
else
  alias l='ls -l'
fi
alias la="l -a"
alias lk="l -s=size"                # Sorted by size
alias lm="l -s=modified"            # Sorted by modified date
alias lc="l --created -s=created"   # Sorted by created date

## own all files/directories passed as arguments
own() {
  sudo chown -R "$(id -un):" "$@"
}

# -- Crypto --------------------------------------------------------------------
alias to='tomb open $TOMB_FILE -k $TOMB_KEY -f'
alias tc='tomb close'

vpn() {
    tomb list || to
    sudo openvpn --config "$HOME/Tomb/vpn/${1}/$(hostname -s).ovpn"
}

## pass + fzf integration
_fzf_pass() {
  local pwdir="${HOME}/.password-store/"
  local stringsize="${#pwdir}"
  ((stringsize+=1))
  find "$pwdir" -name "*.gpg" -print \
    | cut -c "$stringsize"- \
    | sed -e 's/\(.*\)\.gpg/\1/' \
    | fzf_cmd --query "$*"
}
alias _pass='command pass'
pass() {
  _pass show $(_fzf_pass "$@") | head -1
}

alias x509='openssl x509 -noout -text -in '
alias sshfs="\
  sshfs -o idmap=user,allow_other,reconnect,no_readahead,\
    uid=$(id -u),gid=$(id -g),umask=113"

## shmoded ssh-add
ssh-add() {
  chmod 400 "$@" && command ssh-add "$@"
}

# -- Editors -------------------------------------------------------------------
alias s='subl3 -a'
alias svi='sudo vim'

## grep for line content and edit the selected file(s)
srg() {
  local file_list
  file_list=$(rg $* | fzf_cmd)
  [[ ! -z $file_list ]] && s $file_list
}

## open file in Vim at specified line
vil() {
  vi "${1}" +$(< "${1}" | nl -ba -nln | fzf_cmd | cut -d' ' -f1)
}

## open dir in IntelliJ
i() {
  nohup /opt/intellij-idea-ultimate-edition/bin/idea.sh $* 2>/dev/null 1>&2 &
}

# -- Turtles -------------------------------------------------------------------
alias dk='docker-compose'

## docker ps with port information
dps() {
  docker ps $@ \
    --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}" \
    | grep -v pause
}

# -- Z / Misc ------------------------------------------------------------------
alias ccat='pygmentize -g'
alias pbcopy='xsel -b'
alias t="t -t ${HOME}/Dropbox/_Tasks"
alias tlk="t -l k"
alias tlro="t -l ro"
alias tnm='tmuxp load -y ~/.tmuxp/misc.yaml'
alias trizen='trizen --noconfirm'
alias vps="mosh vps -p 1919"

## ssh into tmux session on host
tsh() {
  ssh -t "$@" "tmux attach -t base || exec tmux new -s base"
}

## launch or attach to named tmux session
tn() {
  local s_name
  s_name=${*:-base}
  tmux attach -t "$s_name" || tmux new -s "$s_name"
}

