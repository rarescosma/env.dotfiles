# -- Zsh -----------------------------------------------------------------------
# Path to your oh-my-zsh configuration.
ZSH="$HOME/.oh-my-zsh"

# -- Editor --------------------------------------------------------------------
EDITOR="subl3"
VISUAL="subl3"

# -- Theme ---------------------------------------------------------------------
# Set name of the theme to load.
# Look in <%- paths.oh_my_zsh %>/themes/
ZSH_THEME="ric"

# -- Plugins -------------------------------------------------------------------
# Plugins can be found in <%- paths.oh_my_zsh %>/plugins/
# Custom plugins may be added to <%- paths.oh_my_zsh %>/custom/plugins/
#
# Which plugins would you like to load?
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(archlinux git)

# -- Env -----------------------------------------------------------------------
if [[ -f "$HOME/.env" ]]; then
    source $HOME/.env
fi

# -- Oh My Zsh -----------------------------------------------------------------
source $ZSH/oh-my-zsh.sh

# -- Options -------------------------------------------------------------------
unsetopt correct_all
unsetopt correct

# -- Aliases -------------------------------------------------------------------
if [[ -f "$HOME/.aliases" ]]; then
    source $HOME/.aliases
fi

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
  find ~/.ssh -type f -regex ".*\(id_rsa\|.*\.pem\)" | xargs ssh-add
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

# -- Wisdom --------------------------------------------------------------------
if [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]]; then
  #initialise_ssh_agent
  exec startx -- -dpi 192
else
  clear
  fortune -a /usr/share/fortune/southpark | cowsay -f tux
fi

