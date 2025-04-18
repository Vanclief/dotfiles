# Dotfiles

Simple dotfiles for macOS and Arch Linux.

## Installation

### 1. Set Zsh as your login shell

```bash
chsh -s $(which zsh)
```

### 2. Install required tools

```bash
# macOS
brew install rcm tmux neovim pure
brew tap homebrew/cask-fonts
brew install --cask font-hack-nerd-font

# Arch Linux
yay -S rcm tmux neovim pure-prompt
```

### 3. Configure SSH

```bash
ssh-add ~/.ssh/id_ed25519
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

Add to ~/.ssh/config:

```
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
```

### 4. Clone repository

```bash
git clone git@github.com:Vanclief/dotfiles.git ~/dotfiles
```

### 5. Add Z navigation

```bash
git clone git@github.com:rupa/z ~/dotfiles/z
```

### 6. Configure Alacritty

```bash
mkdir -p ~/.config/alacritty
ln -s ~/dotfiles/config/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml
```

### 7. Deploy dotfiles

```bash
rcup
```

### 8. Add Zsh Git completion

```bash
curl -o ~/.zsh/git-completion.zsh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh
```
