fpath+=("$(brew --prefix)/share/zsh/site-functions")

# Prevent duplicate PATH entries
typeset -U PATH path

export PATH="$HOME/.composer/vendor/bin:/Applications/PhpStorm.app/Contents/MacOS:/opt/homebrew/opt/openjdk/bin:/opt/homebrew/opt/libpq/bin:$PATH"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Initialize completion arrays to prevent compdef errors in subshells
typeset -gA _comps _services _patcomps _postpatcomps 2>/dev/null

ZSH_THEME="robbyrussell"

#ENABLE_CORRECTION="true"

plugins=(zsh-syntax-highlighting zsh-autosuggestions)

if [[ -r ~/.aliases ]]; then
    . ~/.aliases
fi

# ZSH history configuration
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS      # Don't record duplicates
setopt HIST_IGNORE_SPACE     # Don't record commands starting with space
setopt SHARE_HISTORY         # Share history between sessions
setopt APPEND_HISTORY        # Append instead of overwrite
setopt INC_APPEND_HISTORY    # Write immediately, not on exit

source $ZSH/oh-my-zsh.sh

# make tab autosuggest accept key

bindkey '\t\t' autosuggest-accept

autoload -Uz vcs_info
setopt prompt_subst

# Function to truncate branch names
truncate_branch_name() {
    local maxlen=40
    local branch_name=$1
    if (( ${#branch_name} > maxlen )); then
        branch_name="${branch_name[1,maxlen]}.."
    fi
    echo $branch_name
}

zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr " %F{yellow}✚ "
zstyle ':vcs_info:*' unstagedstr " %F{red}● "
zstyle ':vcs_info:*' formats '%b%u%c'
zstyle ':vcs_info:*' actionformats '%b|%a%u%c'
zstyle ':vcs_info:*' branch-hooks
zstyle ':vcs_info:*+branch-hook' branch-hook truncate_branch_name

# Function to show ahead/behind counts
git_ahead_behind() {
    local ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null)
    local behind=$(git rev-list --count HEAD..@{u} 2>/dev/null)
    local result=""
    [[ $ahead -gt 0 ]] && result+="↑$ahead"
    [[ $behind -gt 0 ]] && result+="↓$behind"
    [[ -n $result ]] && echo " %F{cyan}$result%f"
}

precmd() {
    vcs_info
    vcs_info_msg_0_=$(truncate_branch_name "${vcs_info_msg_0_}")
}

PROMPT='%F{yellow}%1~%f %F{magenta}${vcs_info_msg_0_}%f$(git_ahead_behind)%b '
RPROMPT='%~'

# Lazy load NVM for faster shell startup
export NVM_DIR="$HOME/.nvm"
lazy_load_nvm() {
    unset -f nvm node npm npx
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}
nvm() { lazy_load_nvm && nvm "$@"; }
node() { lazy_load_nvm && node "$@"; }
npm() { lazy_load_nvm && npm "$@"; }
npx() { lazy_load_nvm && npx "$@"; }

. "$HOME/.local/bin/env"
