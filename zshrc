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
# macOS sets HISTFILE in /etc/zshrc; Arch sets none, so history would not be saved.
HISTFILE=${HISTFILE:-$HOME/.zsh_history}
HISTSIZE=50000
SAVEHIST=50000

# z - Jump around
export _Z_DATA="$HOME/z-data"
source ~/dotfiles/z/z.sh

# tmux - Start terminal multiplexer, only inside Alacritty.
# Whitelist Alacritty (ALACRITTY_WINDOW_ID) so Orca/WezTerm/other
# terminals don't each nest a tmux session per pane.
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] &&
  [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ] && [ -n "$ALACRITTY_WINDOW_ID" ]; then
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
    if [ -s \"/opt/homebrew/opt/nvm/nvm.sh\" ]; then
      \. \"/opt/homebrew/opt/nvm/nvm.sh\"
      [ -s \"/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm\" ] && \. \"/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm\"
    elif [ -s \"\$NVM_DIR/nvm.sh\" ]; then
      \. \"\$NVM_DIR/nvm.sh\"
      [ -s \"\$NVM_DIR/bash_completion\" ] && \. \"\$NVM_DIR/bash_completion\"
    fi
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
export PATH="$PATH:$HOME/.foundry/bin"

# AGC
export PATH="$HOME/.agent_composer/bin:$PATH"

# Claude Code - always run subagents on Opus, even from a Fable session.
# FORCE makes this win over agent frontmatter and per-call model overrides;
# forks are the only exception and still inherit the parent model.
export CLAUDE_CODE_SUBAGENT_MODEL=opus
export CLAUDE_CODE_SUBAGENT_MODEL_FORCE=1


# Change the color of the prompt segment to be compatible with light theme
prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment black white "%(!.%{%F{yellow}%}.)$USER"
  fi
}

# Add pure prompt
autoload -U promptinit; promptinit
(( ${prompt_themes[(Ie)pure]} )) && prompt pure

zstyle :prompt:pure:git:branch color green
zstyle :prompt:pure:git:dirty color red

# Add auto-suggestions (a manual clone on macOS, the zsh-autosuggestions package on Arch)
for _f in ${ZSH_CUSTOM:-~/.zsh}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh; do
  [[ -f $_f ]] && source $_f && break
done
unset _f

# Git completion setup
fpath=(~/.zsh $fpath)
# Run the completion security audit at most once a day; otherwise use the cached
# dump (-C skips the audit). Rebuilds when ~/.zcompdump is older than 24h.
autoload -Uz compinit
if [[ -n $HOME/.zcompdump(#qN.mh+24) ]]; then compinit; else compinit -C; fi

command -v fzf >/dev/null && source <(fzf --zsh)

# Home, End and Delete: zsh binds none of them, so Delete would print "~".
# Two codes each because terminals send one and tmux the other.
bindkey '^[[H' beginning-of-line
bindkey '^[[1~' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[4~' end-of-line
bindkey '^[[3~' delete-char

# Add ~/.local/bin to PATH for user-installed binaries
export PATH="$HOME/.local/bin:$PATH"

# Machine-specific settings and secrets, kept outside the repo
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"



if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
