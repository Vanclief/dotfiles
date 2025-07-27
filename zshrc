# | |  / /   |  / | / / ____/ /   /  _/ ____/ ____/
# # | | / / /| | /  |/ / /   / /    / // __/ / /_
# # | |/ / ___ |/ /|  / /___/ /____/ // /___/ __/
# # |___/_/  |_/_/ |_/\____/_____/___/_____/_/
# #
# # repo  : https://github.com/vanclief/dotfiles/
# # file  : zshrc

# aliases
[[ -f ~/.aliases ]] && source ~/.aliases

# z - Jump around
export _Z_DATA="$HOME/z-data"
source ~/dotfiles/z/z.sh

# tmux - Start terminal multiplexer
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] &&
  [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
  exec tmux
fi

#  fzf - A command-line fuzzy finder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Golang
export PATH=$PATH:$(go env GOPATH)/bin

# Rust
export PATH=$PATH:$HOME/.cargo/bin

# python - Allow Pip3 binaries to be executed
export PIP_HOME="$(python3 -m site --user-base)"
export PATH="$PATH:$PIP_HOME/bin"


# NVM - Switch node versions
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" ||
  printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# Ruby
# Point to Homebrew’s ruby first
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

# Now compute the gem‑API version & set up GEM_HOME
export GEM_HOME="$HOME/.gem"
RUBY_API_VERSION=$(
  ruby -e 'require "rubygems"; print Gem.ruby_api_version'
)
export PATH="$GEM_HOME/ruby/${RUBY_API_VERSION}/bin:$PATH"

# foundry - Utility for solidity development
export PATH="$PATH:/home/vanclief/.foundry/bin"

# Change the color of the prompt segment to be compatible with light theme
prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment black white "%(!.%{%F{yellow}%}.)$USER"
  fi
}

# Load ENV variables from a .env file
DOTFILES_PATH="$HOME/dotfiles"
[[ -f "$DOTFILES_PATH/.env" ]] && export $(grep -v '^#' "$DOTFILES_PATH/.env" | xargs -0)

# Add pure prompt
autoload -U promptinit; promptinit
prompt pure

zstyle :prompt:pure:git:branch color green
zstyle :prompt:pure:git:dirty color red

# Add auto-suggestions
source ${ZSH_CUSTOM:-~/.zsh}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Git completion setup
fpath=(~/.zsh $fpath)
autoload -Uz compinit && compinit

source <(fzf --zsh)


#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
