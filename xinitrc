#!bin/sh
#
#| |  / /   |  / | / / ____/ /   /  _/ ____/ ____/
#| | / / /| | /  |/ / /   / /    / // __/ / /_
#| |/ / ___ |/ /|  / /___/ /____/ // /___/ __/
#|___/_/  |_/_/ |_/\____/_____/___/_____/_/
#
# repo  : https://github.com/vanclief/dotfiles/
# file  : xinitrc

# Load Xresources
xrdb merge ~/.Xresources

# Set up background and wallpaper
xsetroot -solid "#3E5059"
feh --bg-max ~/Backgrounds/bkg.png

# Start i3
exec i3

true
