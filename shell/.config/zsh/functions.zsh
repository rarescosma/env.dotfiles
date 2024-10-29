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

unalias ls
function ls() {
  if (( $+commands[eza] )); then
    eza -lhg --git --group-directories-first $*
  else
    command ls -lh --color=tty $*
  fi
}
alias lk="ls -s=size"                # Sorted by size
alias lm="ls -s=modified"            # Sorted by modified date
alias lc="ls --created -s=created"   # Sorted by created date
# last modified file in dir
function lmf() {
    local dir="${1:-.}"
    find "$dir" -type f -printf "%T@ %p\n" | sort -n | cut -d' ' -f 2- | tail -n 1
}

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

## glue rg + fzf + bat + vim
vil() {
    local r f l rg_all="" c_style=""
    if test -f "$1"; then
      rg_all='.$'
      c_style="--colors=match:none"
    fi
    r=$(rg --line-number --no-heading --color=always $c_style --smart-case -H $rg_all "$@" 2>/dev/null \
        | fzf -d ':' -n 2.. --ansi --no-sort --preview-window 'down:80%:+{2}-5' \
          --preview 'bat -f --style=numbers --highlight-line {2} {1}' \
        | tail -n1)
    f=$(echo "$r" | cut -d":" -f1)
    l=$(echo "$r" | cut -d":" -f2)
    if ! test -z "$f"; then
        nvim $f +$l
    fi
}

## open dir in IntelliJ
i() {
  local dir
  dir="${*:-./}"
  nohup /opt/intellij-idea-ultimate-edition/bin/idea "$dir" >/dev/null 2>&1 &
  disown
}

# -- Z / Misc ------------------------------------------------------------------
(( $+commands[pbcopy] )) || alias pbcopy="xargs -0 -I% clipcatctl insert -- '%'";
alias t="t -t ${XDG_STATE_HOME}/t"
alias o='open_command'

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
  pids=$(pgrep -f "$@")
  if ! [[ $pids ]]; then
    echo "No processes found." >&2; return 1
  fi
  ps up $(pgrep -f "$@") | hl "$@"
}

## highlight func
hl() {
    local st="$(echo "$@" | tr ' ' '|')"
    grep --color -E "$st|$"
}
