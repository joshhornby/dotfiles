fpath+=("$(brew --prefix)/share/zsh/site-functions")

export PATH="/Applications/PhpStorm.app/Contents/MacOS:/opt/homebrew/opt/openjdk/bin:$PATH"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

#ENABLE_CORRECTION="true"

plugins=(zsh-syntax-highlighting zsh-autosuggestions)

if [[ -r ~/.aliases ]]; then
    . ~/.aliases
fi

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth:erasedups

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=100000
HISTFILESIZE=100000

# store history immediately not only when session terminates
PROMPT_COMMAND='history -a'

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

precmd() {
    vcs_info
    vcs_info_msg_0_=$(truncate_branch_name "${vcs_info_msg_0_}")
}

PROMPT='%F{yellow}%1~%f %F{magenta}${vcs_info_msg_0_}%f%b '
RPROMPT='%~'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

. "$HOME/.local/bin/env"
