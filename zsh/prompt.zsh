autoload colors && colors
# cheers, @ehrenmurdick
# http://github.com/ehrenmurdick/config/blob/master/zsh/prompt.zsh
# Set RHS prompt for git repositories
DIFF_SYMBOL="•"
CHECK_SYMBOL="✔"
CROSS_SYMBOL="✖"
GIT_PROMPT_SYMBOL=""
GIT_PROMPT_PREFIX="%{$fg[violet]%}%B(%b%{$reset_color%}"
GIT_PROMPT_SUFFIX="%{$fg[violet]%}%B)%b%{$reset_color%}"
GIT_PROMPT_AHEAD="%{$fg[teal]%}%B+NUM%b%{$reset_color%}"
GIT_PROMPT_BEHIND="%{$fg[orange]%}%B-NUM%b%{$reset_color%}"
GIT_PROMPT_MERGING="%{$fg[cyan]%}%Bx%b%{$reset_color%}"
GIT_PROMPT_UNTRACKED="%{$fg[yellow]%}%B$CROSS_SYMBOL%b%{$reset_color%}"
GIT_PROMPT_MODIFIED="%{$fg[red]%}%B$CROSS_SYMBOL%b%{$reset_color%}"
GIT_PROMPT_STAGED="%{$fg[green]%}%B$CHECK_SYMBOL%b%{$reset_color%}"
GIT_PROMPT_DETACHED="%{$fg[neon]%}%B!%b%{$reset_color%}"


if (( $+commands[git] ))
then
  git="$commands[git]"
else
  git="/usr/bin/git"
fi

parse_git_detached() {
    if ! git symbolic-ref HEAD >/dev/null 2>&1; then
        echo "${GIT_PROMPT_DETACHED}"
    fi
}

# Show Git branch/tag, or name-rev if on detached head
parse_git_branch() {
  (git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD) 2> /dev/null
}

parse_git_state() {
  # Compose this value via multiple conditional appends.
  local GIT_STATE=""

  local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_AHEAD" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${GIT_PROMPT_AHEAD//NUM/$NUM_AHEAD}
  fi

  local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_BEHIND" -gt 0 ]; then
      if [[ -n $GIT_STATE ]]; then
          GIT_STATE="$GIT_STATE "
      fi
      GIT_STATE=$GIT_STATE${GIT_PROMPT_BEHIND//NUM/$NUM_BEHIND}
  fi

  local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
    if [ -n $GIT_DIR ] && test -r $GIT_DIR/MERGE_HEAD; then
        if [[ -n $GIT_STATE ]]; then
            GIT_STATE="$GIT_STATE "
        fi
    GIT_STATE=$GIT_STATE$GIT_PROMPT_MERGING
  fi

  if [[ -n $(git ls-files --other --exclude-standard :/ 2> /dev/null) ]]; then
    GIT_DIFF=$GIT_PROMPT_UNTRACKED
  fi

  if ! git diff --quiet 2> /dev/null; then
    GIT_DIFF=$GIT_DIFF$GIT_PROMPT_MODIFIED
  fi

  if ! git diff --cached --quiet 2> /dev/null; then
    GIT_DIFF=$GIT_DIFF$GIT_PROMPT_STAGED
  fi

  if [[ -n $GIT_STATE && -n $GIT_DIFF ]]; then
    GIT_STATE="$GIT_STATE "
  fi
    GIT_STATE="$GIT_STATE$GIT_DIFF"

  if [[ -n $GIT_STATE ]]; then
    echo "$GIT_PROMPT_PREFIX$GIT_STATE$GIT_PROMPT_SUFFIX"
  fi
}

git_prompt_info () {
 ref=$($git symbolic-ref HEAD 2>/dev/null) || return
#echo "(%{\e[0;33m%}${ref#refs/heads/}%{\e[0m%})"
  echo "${ref#refs/heads/}"
}

unpushed () {
  $git cherry -v @{upstream} 2>/dev/null
}

need_push () {
  if [[ $(unpushed) == "" ]]
  then
    echo " "
  else
    echo " with %{$fg_bold[magenta]%}unpushed%{$reset_color%} "
  fi
}

# Credit: https://github.com/jackfranklin/dotfiles/blob/6e150a68eb1970789b3a8a39e584294880e85650/zsh/prompt#L42

# Current directory, truncated to 3 path elements (or 4 when one of them is "~")
# The number of elements to keep can be specified as ${1}
directory_name() {
  local sub=${1}
  if [[ "${sub}" == "" ]]; then
      sub=3
  fi
  local len="$(expr ${sub} + 1)"
  local full="$(print -P "%d")"
  local relfull="$(print -P "%~")"
  local shorter="$(print -P "%${len}~")"
  local current="$(print -P "%${len}(~:.../:)%${sub}~")"
  local last="$(print -P "%1~")"

  # Longer path for '~/...'
  if [[ "${shorter}" == \~/* ]]; then
      current=${shorter}
  fi

  local truncated="$(echo "${current%/*}/")"

  # Handle special case of directory '/' or '~something'
  if [[ "${truncated}" == "/" || "${relfull[1,-2]}" != */* ]]; then
      truncated=""
  fi

  # Handle special case of last being '/...' one directory down
  if [[ "${full[2,-1]}" != "" && "${full[2,-1]}" != */* ]]; then
      truncated="/"
      last=${last[2,-1]} # take substring
  fi

  echo "%{$fg[red]%}${truncated}%{$fg[orange]%}%B${last}%b%{$reset_color%}"
}

# If inside a Git repository, print its branch and state
RPR_SHOW_GIT=true # Set to false to disable git status in rhs prompt
function git_prompt_string() {
    if [[ "${RPR_SHOW_GIT}" == "true" ]]; then
        local git_where="$(parse_git_branch)"
        local git_detached="$(parse_git_detached)"
        [ -n "$git_where" ] && echo " $GIT_PROMPT_SYMBOL$(parse_git_state)$GIT_PROMPT_PREFIX%{$fg[magenta]%}%B${git_where#(refs/heads/|tags/)}%b$git_detached$GIT_PROMPT_SUFFIX"
    fi
}

export PROMPT=$'\nin $(directory_name) $(git_prompt_string)$(need_push)\n› '
set_prompt () {
  export RPROMPT="%{$fg_bold[red]%}%{$reset_color%}"
}

precmd() {
  title "zsh" "%m" "%55<...<%~"
  set_prompt
}
