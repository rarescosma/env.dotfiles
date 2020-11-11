alias sudo='sudo -E '

# -- Fs ------------------------------------------------------------------------
unalias z
alias ...='cd ../../'
alias ....='cd ../../../'
alias rg="rg --hidden --follow --smart-case"
alias locate='locate -i'

if (( $+commands[rmtrash] )); then
  alias rm='rmtrash'
  alias rm!='trash-put'
fi

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

permfix() {
  local d
  d=${1:-./}
  sudo chown -R "$(id -un)": "$d"
  find "$d" -type d -exec chmod 775 {} \; -exec chmod u-s {} \; -exec chmod g+s {} \;
  find "$d" -type f -exec chmod 664 {} \;
}

# -- Crypto --------------------------------------------------------------------
to() {
  tomb list || {
    tomb open $TOMB_FILE -k $TOMB_KEY -f \
    && kick autokey-gtk \
  }
}

tc() {
  tomb list && {
    sudo -E pkill -f openvpn
    tomb close
    kick autokey-gtk
  }
}

vpn() {
  local vpn_config log_path old_name
  vpn_config="vpn/${1}/$(hostname -s).ovpn"
  log_path="/tmp/vpn-${1}.log"; echo -n > "$log_path"

  to || return

  # pre-hooks
  old_name=$(trename "vpn-${1}")
  {
    tail -f "$log_path" | sed '/Initialization Sequence Completed/ q';
    sudo systemctl restart https_dns_proxy;
  } &

  sudo openvpn \
    --config "$HOME/Tomb/${vpn_config}" \
    --mute-replay-warnings | tee "$log_path"

  # post-hooks
  wait
  trename "${old_name}"
  sudo systemctl restart https_dns_proxy
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
alias s="$(echo $VISUAL | cut -d' ' -f1)"
alias svi='sudo vim'

## edit immutable files
svii() {
  sudo chattr -i "${1}"
  sudo vim "${1}"
  sudo chattr +i "${1}"
}

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
  nohup /opt/intellij-idea-ultimate-edition/bin/idea.sh $* >/dev/null 2>&1 &
  disown
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
alias t="t -t ${HOME}/Dropbox/apps/t"
alias tlk="t -l k"
alias tlro="t -l ro"
alias tnm='tmuxp load -y ~/.tmuxp/misc.yaml'
alias trizen='trizen --noconfirm'
alias o='xdg-open'

## kill and restart process
kick() {
  local process="${@}"
  command -v "${process}" >/dev/null || return
  pkill -f "${process}"
  nohup "${process}" >/dev/null 2>&1 &
  disown
}

## remind after $1 seconds
remind() {
  local seconds="${1}"
  shift
  {
    sleep "${seconds}"
    notify-send "reminder:" "$*" -u critical
  } >/dev/null 2>&1 &
  disown
}

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

## rename tmux pane
trename() {
  local p_name
  p_name=${*:-zsh}
  echo >&2 "Renaming tmux pane to: \"${p_name}\""

  local old_name
  old_name=""

  if [ -n "$TMUX_PANE" ]; then
    old_name=$(tmux display-message -p '#W')
    tmux rename-window -t"${TMUX_PANE}" "$p_name"
  fi

  echo "$old_name"
}
