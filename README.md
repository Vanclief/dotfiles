# dotfiles-arch

I used to have a pretty heavy dotfile configuration but after falling in love with simplicity, I keep a very lightweight configuration. 

## Requirements

Install [thoughtbot dotfiles](https://github.com/thoughtbot/dotfiles)

## Instal

Clone into your machine:

`git clone git://github.com/vanclief/dotfiles-arch.git ~/dotfiles-local` 

Run rcup:

`rcup`

Install Oh-My-Zsh

`sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`

Add z:

`git clone git://github.com/rupa/z ~/dotfiles-local/z`

Install powerline:

`sudo pacman -Sy powerline powerline-fonts powerline-vim`
