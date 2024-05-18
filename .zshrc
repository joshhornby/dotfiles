fpath+=("$(brew --prefix)/share/zsh/site-functions")

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

ENABLE_CORRECTION="true"

plugins=(zsh-syntax-highlighting zsh-autosuggestions git)

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

autoload -Uz vcs_info
setopt prompt_subst

zstyle ':vcs_info:*' formats " [%b]%u%c"
zstyle ':vcs_info:*' actionformats " [%b|%a]%u%c"
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' check-for-staged-changes true

precmd() {
    vcs_info
}

PROMPT='%F{green}%n@%m%f %F{yellow}%1~%f %F{magenta}${vcs_info_msg_0_}%f%b '
RPROMPT='%~'


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
