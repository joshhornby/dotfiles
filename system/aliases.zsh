# grc overides for ls
#   Made possible through contributions from generous benefactors like
#   `brew install coreutils`
if $(gls &>/dev/null)
then
  alias ls="gls -F --color"
  alias l="gls -lAh --color"
  alias ll="gls -l --color"
  alias la='gls -A --color'
fi

# cd
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# dotfiles
alias df="cd ~/.dotfiles"

# misc
alias edit-host="sudo vim /etc/hosts"

alias nah='git clean -df; git checkout -- .'
