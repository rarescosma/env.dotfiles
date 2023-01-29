# Tomb

LOCAL_PATH="$HOME/tomb"
KEY="$HOME/heart.jpg"

tomb::lo() {
  local nxt=$(sudo losetup -f)
  local minor=$(echo $nxt | cut -d"p" -f2)
  sudo mknod -m660 $nxt b 7 $minor
}

tomb::open() {
  tomb::lo
  tomb open $LOCAL_PATH -k $KEY
}

alias to='tomb::open'
alias tc='tomb close'
