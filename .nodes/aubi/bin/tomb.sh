# Tomb

DX="$HOME/bin/dropbox_uploader"
DX_PATH="_Storage/tomb"
LOCAL_PATH="$HOME/tomb"
KEY="$HOME/heart.jpg"

tomb::maybe() {
  local msg="$1"
  local func="$2"

  while true; do
    read -p " > $msg " yn
    case $yn in
      [Yy]* ) $func; break;;
      [Nn]* ) break;;
      * ) echo "Please answer yes or no.";;
    esac
  done
}

tomb::maybe_pull() {
  tomb::maybe "Pull tomb from Dropbox?" tomb::pull
}

tomb::maybe_push() {
  tomb::maybe "Push tomb to Dropbox?" tomb::push
}

tomb::lo() {
  local nxt=$(sudo losetup -f)
  local minor=$(echo $nxt | cut -d"p" -f2)
  sudo mknod -m660 $nxt b 7 $minor
}

tomb::pull() {
  test $LOCAL_PATH && mv $LOCAL_PATH $LOCAL_PATH.old
  $DX download $DX_PATH $LOCAL_PATH
}

tomb::push() {
  $DX upload $LOCAL_PATH $DX_PATH
}

tomb::open() {
  tomb::lo
  tomb open $LOCAL_PATH -k $KEY
}

alias to='tomb::maybe_pull; tomb::open'
alias tc='tomb close; tomb::maybe_push'

