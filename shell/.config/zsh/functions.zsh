alias sudo='sudo -E '

# -- Fs ------------------------------------------------------------------------
unalias z 2>/dev/null
alias ...='cd ../../'
alias ....='cd ../../../'
alias rg="rg --hidden --follow --smart-case"
alias locate='locate -i'

if (( $+commands[rmtrash] )); then
  alias rm='rmtrash'
  alias rm!='/sbin/rm'
fi

if (( $+commands[exa] )); then
  alias l="exa -lhg --git --group-directories-first"
else
  alias l='ls -lh'
fi
alias la="l -ah"
alias lk="l -s=size"                # Sorted by size
alias lm="l -s=modified"            # Sorted by modified date
alias lc="l --created -s=created"   # Sorted by created date

## own all files/directories passed as arguments
own() {
  test -z "$@" && exit 1
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
alias x509='openssl x509 -noout -text -in '
alias sshfs="\
  sshfs -o idmap=user,allow_other,reconnect,no_readahead,\
uid=$(id -u),gid=$(id -g),umask=113"

alias to=",tomb ,open"
alias tc=",tomb ,close"

## pass + fzf integration
_fzf_pass() {
  local pwdir="${HOME}/.local/share/pass/"
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

# -- Editors -------------------------------------------------------------------
s() {
  local f
  f="$(readlink -f "$@")"
  if test -w "$f"; then
      $VISUAL "$@"
  else
    if test -f "$f"; then
        sudo $VISUAL "$@"
    else
      if ! test -e "$f"; then
        local p
        p="$(dirname "$@")"
        if test -w "$p"; then
          $VISUAL "$@"
        else
          sudo $VISUAL "$@"
        fi
      else
        $VISUAL "$@"
      fi
    fi
  fi
}

## edit immutable files
svii() {
  sudo chattr -i "${1}"
  sudo vim "${1}"
  sudo chattr +i "${1}"
}

## open file in Vim at specified line
vil() {
  nvim "${1}" +$(< "${1}" | nl -ba -nln | fzf_cmd | cut -d' ' -f1)
}

## glue rg + fzf + bat + vim
vig() {
    local r f l
    r=$(rg --line-number --no-heading --color=always --smart-case "$@" \
        | fzf -d ':' -n 2.. --ansi --no-sort --preview-window 'down:20%:+{2}' \
          --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' \
        | tail -n1)
    f=$(echo "$r" | cut -d":" -f1)
    l=$(echo "$r" | cut -d":" -f2)
    if ! test -z "$f"; then
        echo "nvim $f +$l"
        nvim $f +$l
    fi
}

## open dir in IntelliJ
i() {
  local dir
  dir="${*:-./}"
  nohup /opt/intellij-idea-ultimate-edition/bin/idea.sh "$dir" >/dev/null 2>&1 &
  disown
}

# -- Z / Misc ------------------------------------------------------------------
(( $+commands[pbcopy] )) || alias pbcopy='xsel -b';
alias t="t -t ${HOME}/sync/apps/t"
alias tnm='tmuxp load -y ~/.tmuxp/misc.yaml'
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
  tmux new-session -A -s "$s_name" \
    -e "SSH_CLIENT=$SSH_CLIENT" \; setenv SSH_CLIENT "$SSH_CLIENT"
}

## user-friendly ps | grep
psgrep() {
  local pids
  pids=$(pgrep -f $@)
  if ! [[ $pids ]]; then
    echo "No processes found." >&2; return 1
  fi
  ps up $(pgrep -f $@)
}
