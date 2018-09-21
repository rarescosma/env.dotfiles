# Partition scheme
* +100M -> boot (n -> p)
* the rest -> system (n -> p)

# Qemu steps
```
# download the raspbian qemu kernel & arch for raspi
./qemu.sh prep

# create a qcow base image for emulating raspi
./qemu.sh create_base_image

# start raspi
./qmeu.sh run
```

# Gmrender steps
```
# do system upgrade + install deps
./gmrender.sh do_packages

# create user, allow sudo, close down ssh
./gmrender.sh do_user

# build gmediarender-resurrect from AUR
./gmrender.sh do_gmrender

# configure and start gmediarender
./gmrender.sh do_gmrender_conf
```

# Fix switching bug

Start gmrender with the `--gstout-buffer-duration=0` flag.
