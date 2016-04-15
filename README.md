# dotfiles

This repository consists of configuration for any tools I use within my [Arch Linux][arch] development environment. I link all of this configuration into my home directory using [stow][].

## Installation

Firstly, clone this repository down to `~/dotfiles`, a few things assume it's kept there, sorry.

Presuming you're using Arch Linux, you can just run `make`. This will install everything listed in `packages.txt` (including [yaourt][] and [infinality][]!), link all of the configuration into your home directory then switch the default shell to [zsh][].

```bash
# Pre-awesome Linux environment.

make

# Awesome Linux environment.
```

To perform a system wide update you can execute `update` from within a [zsh][] shell.

## Unlicenced

Find the full [unlicense][] in the `UNLICENSE` file, but here's a snippet.

>This is free and unencumbered software released into the public domain.
>
>Anyone is free to copy, modify, publish, use, compile, sell, or distribute this software, either in source code form or as a compiled binary, for any purpose, commercial or non-commercial, and by any means.

Do what you want. Learn as much as you can. Unlicense more software.

[unlicense]: http://unlicense.org/
[arch]: https://www.archlinux.org/
[stow]: http://www.gnu.org/software/stow/
[yaourt]: https://aur.archlinux.org/packages/yaourt/
[zsh]: https://wiki.archlinux.org/index.php/zsh
[infinality]: https://wiki.archlinux.org/index.php/Infinality
