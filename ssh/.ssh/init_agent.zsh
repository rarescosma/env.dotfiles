#!/usr/bin/env zsh

export SSH_ENV=$HOME/.ssh/environment

function setenv {
  export $1=$2
}

function initialise_ssh_agent {
  re='^[0-9]+$'
  if [[ "$SSH_AGENT_PID" =~ $re ]] ; then
    ps -ef | grep $SSH_AGENT_PID | grep ssh-agent > /dev/null 2>&1
    if [ $? -eq 0 ]; then
      test_identities
    fi
  else
    if [ -f $SSH_ENV ]; then
      . $SSH_ENV > /dev/null
    fi
    ps -ef | grep $SSH_AGENT_PID | grep -v grep | grep ssh-agent > /dev/null 2>&1
    if [ $? -eq 0 ]; then
      test_identities
    else
      start_agent
    fi
  fi
}

function add_keys {
  if [[ ! -z $TMUX ]]; then
    SESS=`tmux display-message -p '#S'`
    if [[ "scratchpad" != "$SESS" ]]; then
      find ~/.ssh -type f -regex ".*\(id_rsa\|.*\.pem\)" | xargs ssh-add
    fi
  fi
}

function start_agent {
  ssh-agent -c | sed 's/^echo/#echo/' > $SSH_ENV
  chmod 600 $SSH_ENV
  . $SSH_ENV > /dev/null
  add_keys
}

function test_identities {
  ssh-add -l | grep "The agent has no identities" > /dev/null
  if [ $? -eq 0 ]; then
    add_keys
    if [ $? -eq 2 ]; then
      start_agent
    fi
  fi
}

if [[ ! -z $TMUX ]]; then
  initialise_ssh_agent
fi
