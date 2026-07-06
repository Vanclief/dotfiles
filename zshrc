# | |  / /   |  / | / / ____/ /   /  _/ ____/ ____/
# # | | / / /| | /  |/ / /   / /    / // __/ / /_
# # | |/ / ___ |/ /|  / /___/ /____/ // /___/ __/
# # |___/_/  |_/_/ |_/\____/_____/___/_____/_/
# #
# # repo  : https://github.com/vanclief/dotfiles/
# # file  : zshrc

# aliases
[[ -f ~/.aliases ]] && source ~/.aliases

# Increase retained shell history beyond macOS /etc/zshrc defaults.
HISTSIZE=50000
SAVEHIST=50000

# z - Jump around
export _Z_DATA="$HOME/z-data"
source ~/dotfiles/z/z.sh

# WezTerm shell integration (OSC 7 cwd so splits/tabs inherit the directory).
# Only under WezTerm; does nothing in Alacritty/tmux.
[ -n "$WEZTERM_PANE" ] && [ -f /Applications/WezTerm.app/Contents/Resources/wezterm.sh ] &&
  source /Applications/WezTerm.app/Contents/Resources/wezterm.sh

# tmux - Start terminal multiplexer.
# Skipped under WezTerm so the native-multiplexing trial can run there;
# still auto-starts everywhere else (e.g. Alacritty).
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] &&
  [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ] && [ -z "$WEZTERM_PANE" ]; then
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
export NVM_DIR="$HOME/.nvm"
# Lazy-load nvm: defer the ~450ms init until node/npm/npx/nvm is first used.
# Trade-off: no automatic `nvm use` at shell start; the project version loads
# on first node/npm run.
# Each wrapper is self-contained (no shared helper): tools that replay shell
# functions from a snapshot (e.g. Claude Code) drop underscore-prefixed
# helpers, and a wrapper calling a missing helper recurses forever. Unsetting
# the wrappers before re-invoking also makes recursion impossible.
for _c in nvm node npm npx; do
  eval "${_c}() {
    unset -f nvm node npm npx 2>/dev/null
    [ -s \"/opt/homebrew/opt/nvm/nvm.sh\" ] && \. \"/opt/homebrew/opt/nvm/nvm.sh\"
    [ -s \"/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm\" ] && \. \"/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm\"
    ${_c} \"\$@\"
  }"
done
unset _c

# Put the default node version's bin dir on PATH cheaply (a glob, no fork, no
# nvm.sh source). Without this, globals installed under that node (node, npm,
# and CLIs like `pi`) are invisible by name until a wrapper above fires. nvm
# still lazy-loads for `nvm use` / version switches.
if [[ -r "$NVM_DIR/alias/default" ]]; then
  _nvm_bin=("$NVM_DIR/versions/node/v$(<"$NVM_DIR/alias/default")"*/bin(Nn))
  [[ -n "$_nvm_bin" ]] && export PATH="${_nvm_bin[-1]}:$PATH"
  unset _nvm_bin
fi


# This use to be the old config, probably linux based
# export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" ||
# printf %s "${XDG_CONFIG_HOME}/nvm")"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# Ruby
# Point to Homebrew’s ruby first
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

# Now compute the gem‑API version & set up GEM_HOME.
# Cache it: forking ruby on every shell costs ~50-150ms and the value only
# changes when the ruby binary is upgraded, so recompute only when that happens.
export GEM_HOME="$HOME/.gem"
_ruby_api_cache="$HOME/.cache/ruby_api_version"
if [[ ! -f "$_ruby_api_cache" || "$(command -v ruby)" -nt "$_ruby_api_cache" ]]; then
  mkdir -p "${_ruby_api_cache:h}"
  ruby -e 'require "rubygems"; print Gem.ruby_api_version' > "$_ruby_api_cache"
fi
export PATH="$GEM_HOME/ruby/$(<"$_ruby_api_cache")/bin:$PATH"

# foundry - Utility for solidity development
export PATH="$PATH:/home/vanclief/.foundry/bin"

# AGC
export PATH="$HOME/.agent_composer/bin:$PATH"


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
# Run the completion security audit at most once a day; otherwise use the cached
# dump (-C skips the audit). Rebuilds when ~/.zcompdump is older than 24h.
autoload -Uz compinit
if [[ -n $HOME/.zcompdump(#qN.mh+24) ]]; then compinit; else compinit -C; fi

source <(fzf --zsh)

# Add ~/.local/bin to PATH for user-installed binaries
export PATH="$HOME/.local/bin:$PATH"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"



