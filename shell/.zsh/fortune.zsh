clear
read -r -d '' OK_COWS <<'EOF'
moose
daemon
three-eyes
bunny
kitty
elephant
small
skeleton
dragon
koala
bud-frogs
vader
default
tux
EOF
fortune -n 300 -s | cowsay -W 80 -f $(echo "$OK_COWS" | shuf -n 1)
