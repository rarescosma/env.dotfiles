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
alias sudo='sudo -E '

if (( $+commands[exa] )); then
  alias l="exa -lhg --git --group-directories-first"
else
  alias l='ls -l'
fi
alias la="l -a"
alias lk="l -s=size"                # Sorted by size
alias lm="l -s=modified"            # Sorted by modified date
alias lc="l --created -s=created"   # Sorted by created date

alias to='tomb open $TOMB_FILE -k $TOMB_KEY -f'
alias tc='tomb close'
alias sshfs="sshfs -o idmap=user,allow_other,reconnect,no_readahead,uid=$(id -u),gid=$(id -g),umask=113"

## own all files/directories passed as arguments
own() {
  sudo chown -R $(id -un): "$@"
}

# -- Python --------------------------------------------------------------------
alias pipu='pip install -U pip'
alias pe='pipenv'

## automate .venv creation for pip/pipenv-based projects
nvenv() {
  deactivate 2>/dev/null
  if [ -f Pipfile ]; then
    pipenv install --dev --skip-lock "$@"
  else
    [ -f requirements.txt ] && pipenv install -r requirements.txt --skip-lock "$@"
  fi
  source .venv/bin/activate
  ln -sf "$_VENDOR/../devel/.pythonenv" .env
  touch .envlocal
  pip install -e .
  [ -f test-requirements.txt ] && pip install -r test-requirements.txt
}

rvenv() {
  deactivate 2>/dev/null
  rm -rf .venv .env Pipfile Pipfile.lock .python-version
}

# -- Editing -------------------------------------------------------------------
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
  /opt/intellij-idea-ultimate-edition/bin/idea.sh $* 2>/dev/null 1>&2 &
}

# -- Turtles -------------------------------------------------------------------
alias k='kubectl'
alias dk='docker-compose'

## docker ps with port information
dps() {
  docker ps $@ \
    --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}" \
    | grep -v pause
}

## list ec2 instances belonging to team
ec2-list() {
  local team="$1"; shift
  ec2-toys list --filters "Name=instance-state-name,Values=running Name=tag:Team,Values=$team" | grep linux
}

## output instance IP after filtering
ec2-ip() {
  memoize ec2-list $TEAM_TAG | fzf_cmd --query "$*" | awk '{print $2}'
}

# -- Pass ----------------------------------------------------------------------
_fzf_pass() {
  local pwdir="${HOME}/.password-store/"
  local stringsize="${#pwdir}"
  ((stringsize+=1))
  find "$pwdir" -name "*.gpg" -print \
    | cut -c "$stringsize"- \
    | sed -e 's/\(.*\)\.gpg/\1/' \
    | fzf_cmd --query "$*"
}
passs() {
  pass show $(_fzf_pass "$@") | head -1
}

# -- Z / Misc ------------------------------------------------------------------
alias vps="mosh vps -p 1919"
alias t="t -t ${HOME}/Dropbox/_Tasks"
alias tlk="t -l k"
alias tlro="t -l ro"
alias trizen='trizen --noconfirm'
alias ccat='pygmentize -g'
alias x509='openssl x509 -noout -text -in '
alias pbcopy='xsel -b'

## ssh into tmux session on host
tsh() {
  ssh -t "$@" "tmux attach -t base || exec tmux new -s base"
}

## shmoded ssh-add
ssh-add() {
  chmod 400 "$@" && command ssh-add "$@"
}

## launch or attach to named tmux session
tn() {
  local s_name
  s_name=${*:-base}
  tmux attach -t "$s_name" || tmux new -s "$s_name"
}

alias tnm='tmuxp load -y ~/.tmuxp/misc.yaml'
