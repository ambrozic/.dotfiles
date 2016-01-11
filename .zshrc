###########################################
# EXPORTS
############################################
export LANG=en_US.UTF-8
export LDFLAGS="-L/usr/local/opt/libxml2/lib -L/usr/local/opt/lapack/lib -L/usr/local/opt/zlib/lib"
export CPPFLAGS="-I/usr/local/opt/libxml2/include -I/usr/local/opt/lapack/include -I/usr/local/opt/zlib/include"
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad
export HISTCONTROL=ignoreboth:erasedups

############################################
# COLORS
# https://jonasjacek.github.io/colors/
############################################
GRAY="%F{250}"
GREEN="%F{10}"
CYAN="%F{51}"
BLUE="%F{75}"
PURPLE="%F{135}"
RED="%F{196}"
PINK="%F{207}"
YELLOW="%F{226}"
ORANGE="%F{208}"
RESET="%f"

gray="\e[38;5;250m"
green="\e[38;5;10m"
cyan="\e[38;5;51m"
blue="\e[38;5;75m"
purple="\e[38;5;135m"
red="\e[38;5;196m"
pink="\e[38;5;207m"
yellow="\e[38;5;226m"
orange="\e[38;5;208m"
reset="\e[0m"

############################################
# ZSH OPTIONS
############################################
setopt AUTO_CD
setopt GLOB_COMPLETE
setopt NO_CASE_GLOB
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_VERIFY
setopt HIST_EXPIRE_DUPS_FIRST 
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt CORRECT
unsetopt CORRECT_ALL
setopt AUTO_MENU
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt PROMPT_SUBST

############################################
# ZSH VARIABLES
############################################
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

HISTFILE=${ZDOTDIR:-$HOME}/.history
HISTSIZE=5000
SAVEHIST=5000
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=67"
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none

############################################
# ZSH BINDINGS
############################################
bindkey '\e[3~' delete-char

############################################
# ZSH SETUP
############################################
autoload -Uz compinit && compinit

# case insensitive path-completion
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

# partial completion suggestions
zstyle ':completion:*' list-suffixes
zstyle ':completion:*' expand prefix suffix

############################################
# ALIASES
############################################
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ll="ls -aGlsph"
alias tailfn="tail -f -n 1000"
alias shtop="sudo htop"
alias reload="print '  reloading shell profile ...' && source ~/.zshrc"

############################################
# BREW
############################################
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

############################################
# GIT PROMPT
############################################
function get_git_info () {
	local branch stashed untracked uncommitted unpushed unstaged

	# check if the current directory is in a git repository
	if [[ $(git rev-parse --is-inside-work-tree &>/dev/null; printf "%s" $?) -gt 0 ]]; then
        return
    fi

    # ensure index is up to date
    git update-index --really-refresh  -q &>/dev/null
    
    branch="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || git rev-parse --short HEAD 2> /dev/null || printf "(unknown)")"

    # check for stashed files
    if $(git rev-parse --verify refs/stash &>/dev/null); then
        stashed="${cyan}•${reset}"
    fi

    # check for un-tracked files
    if [ $(git status --porcelain 2>/dev/null| grep "^??" | wc -l) != 0 ]; then
        untracked="${red}?${reset}"
    fi

    # check for un-committed changes in the index
    if [ "$(git diff --name-only --staged)" ]; then
        uncommitted="${blue}+${reset}"
    fi

    # check for un-pushed commits
    if [[ $(git branch -v | grep $branch) =~ ("[ahead "([[:digit:]]*)) ]]; then
        unpushed="${green}!${reset}"
    fi

    # check for un-staged changes
    if [ "$(git diff --name-only)" ] ; then
        unstaged="${yellow}*${reset}"
    fi

    print " ${cyan}on${reset} ${purple}$branch${reset}$stashed$untracked$uncommitted$unpushed$unstaged"
}

############################################
# GIT REPOSITORY INFO
############################################
function gitinfo() {
    local branch
    
	# check if the current directory is in a git repository
    if [[ $(git rev-parse --is-inside-work-tree &>/dev/null; printf "%s" $?) -gt 0 ]]; then
        return
    fi

    # ensure index is up to date
    git update-index --really-refresh  -q &>/dev/null

    branch="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || git rev-parse --short HEAD 2> /dev/null || printf "(unknown)")"
    # git repository info
    print " ${yellow}* un-staged   $(git diff --name-only | wc -l)${reset}"
    print " ${green}! un-pushed   $(git diff $branch..HEAD | wc -l)${reset}"
    print " ${blue}+ un-committed$(git diff --name-only --staged | wc -l)${reset}"
    print " ${red}? un-tracked  $(git status --porcelain | wc -l)${reset}"
    print " ${cyan}• stashed     $(git stash list | wc -l)${reset}"
}

############################################
# VIRTUAL ENV PROMPT
############################################
function get_venv_info () {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        print "${CYAN} env ${ORANGE}$(pyenv version-name)${RESET}"
    fi
}

############################################
# VIRTUALENV INFO
############################################
function venv () {
    print ${blue}" "Version: ${green}$(python -V || printf '-')${reset}
    print ${blue}""Location: ${green}$(pyenv which python || printf '-')${reset}
    print ${blue}"  "Origin: ${green}$(pyenv version-origin || printf '-')${reset}
    print ${blue}" "Virtual: ${green}${VIRTUAL_ENV:=-}${reset}
}

############################################
# VIRTUALENV GENERATOR
############################################
function xvenv() {
    local vn name answer
    local versions=( $( pyenv versions --bare --skip-aliases | grep -v / | sed 's/:.*//' ) )
    local length=${#versions[@]}

    if [ $length -eq 0 ]; then
        print "No pyenv python versions available"
        return
    fi

    print "${cyan}Available pyenv versions:${reset}"
    for i in {1..$length} ; do
        print "  ${blue}[${green}$[$i]${blue}]${reset} ${yellow} $versions[i] ${reset}"
    done

    vared -p "Select number [${GREEN}$[$length]${RESET}]: " -c vn
    vn=${vn:-$length}
    if [[ ($vn -lt 1) || ($vn -gt $length ) ]] ; then
        print "Invalid version selected"
        return
    fi
    local version=${versions[$[$vn]]}

    vared -p "Name [${GREEN}${PWD##*/}${RESET}]: " -c name
    name=${name:-${PWD##*/}}

    vared -p "Create new virtual environment ${GREEN}$name${RESET} from version ${GREEN}$version${RESET}? [Yn]: " -c answer
    if [[ ${answer:-Y} != "Y" ]]; then
        print "Canceled"
        return
    fi

    pyenv virtualenv $version $name
    echo $name > .python-version
    print "Using" $( pyenv version )
}

############################################
# GIT OPEN REPOSITORY PAGE
############################################
function gitopen() {
    if [ $(git rev-parse --is-inside-work-tree &>/dev/null; printf "%s" $?) != 0 ]; then
        printf "Not a git repository.\n"
        return
    fi

    local url=$(git config --get remote.origin.url)
    url=${url/\:/\/}
    url=${url/git\@/https://}
    url=${url/\.git/}
    open "$url" &> /dev/null
    return
}

############################################
# GREP SEARCH
############################################
function search () {

    if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]] || [[ "$#" -eq 0 ]]; then
        print ""
        print "Usage:"
        print "  search . term      # finds 'term' in all files"
        print "  search . term \*   # finds 'term' in all files"
        print "  search . term .txt # finds 'term' in *.txt files"
        print "  search . term .\*  # finds 'term' in .* files"
        print ""
        return
    fi

    local where="$1"
    local what="$2"
    local in="$3"
    
    if [[ "$#" -eq 2 ]]; then
        local in="*"
    fi
    
    grep \
        --recursive \
        --ignore-case \
        --line-number \
        --color="always" \
        --binary-file="without-match" \
        --context=1 \
        --exclude-dir=".env" \
        --exclude-dir="site-packages" \
        --exclude-dir="*.egg" \
        --include="$in" \
        --regexp="$what" $where

    print "Finished searching in '${blue}$where${reset}' for '${green}$what${reset}' in '${orange}$in${reset}' files";
}

############################################
# CLEAN 
############################################
function clean() {
    find / -name '.DS_Store' -type f -delete
    print "Removed all '.DS_Store' files"
}

############################################
# BACKUP
############################################
function backup() {
    local answer
    local backup=/Users/ambrozic/Dropbox/Backup/
    mkdir -p $backup
    vared -p "Dry run first? [nY]: " -c answer

    dry_run="n"
    if [[ $answer = "n" ]]; then
        dry_run=""
    fi

    sources="/Users/ambrozic/Development/"
    for src in $sources; do
        dest="$backup`basename $src`"
        rsync -avh$dry_run \
        --delete \
        --stats \
        --progress \
        --exclude=".*/" \
        --exclude=".*" \
        --exclude="__pycache__" \
        --exclude="node_modules" \
        --exclude="build" \
        --exclude="android" \
        --exclude="ios" \
        --exclude="rust" \
        --exclude="parity" \
        --exclude="*.egg-*" \
        $src $dest
    done
}

############################################
# PROMPT
############################################
function get_prompt () {
    local prefix="${ORANGE}┏╸${RESET}"
    local suffix="${ORANGE}┗╸${RESET}"
    local user="${YELLOW}%n${RESET}"
    local at=" ${CYAN}at${RESET} "
    local host="${YELLOW}%m${RESET}"
    local in=" ${CYAN}in${RESET} "
    local location="${BLUE}%~${RESET}"
    local venv=$(get_venv_info)
    local git="$(get_git_info)"
    local clock="${GREEN}%*${RESET}"
    PROMPT="${prefix}${user}${at}${host}${in}${location}${venv}${git}"$'\n'"${suffix}"
    RPROMPT="${clock}"
}

############################################
# TIMEPULSE
############################################
function timepulse () {
    local url=$1
    curl -kLs -o /dev/null -w "
       time_namelookup: %{time_namelookup}
          time_connect: %{time_connect}
       time_appconnect: %{time_appconnect}
      time_pretransfer: %{time_pretransfer}
    time_starttransfer: %{time_starttransfer}
            time_total: %{time_total}
         time_redirect: %{time_redirect}\n\n" $url
}

############################################
# LOAD FUNTIONS
############################################
precmd_functions+=( 
    # vcs_info
    get_prompt 
)

############################################
# PYTHON - very slow
############################################
export PROJECT_HOME=$HOME/Development
export PYTHONDONTWRITEBYTECODE=0
export PYENV_ROOT="${HOME}/.pyenv"
if [ -d "${PYENV_ROOT}" ]; then
    export PATH="${PYENV_ROOT}/bin:${PATH}"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

############################################
# GO
############################################
GOROOT="/usr/local/bin"
export GOROOT=$GOROOT
launchctl setenv GOROOT $GOROOT

GOPATH="$HOME/Development/go"
export GOPATH=$GOPATH
launchctl setenv GOPATH $GOPATH

GOBIN="$GOPATH/bin"
export GOBIN=$GOBIN
launchctl setenv GOBIN $GOBIN

############################################
# RUST
############################################
RUST_SRC_PATH="/usr/local/rust/src"
export RUST_SRC_PATH=$RUST_SRC_PATH
PATH="$HOME/.cargo/bin:${PATH}"

############################################
# ANDROID
############################################
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/platform-tools

############################################
# GOOGLE CLOUD SDK
############################################
export CLOUDSDK_PYTHON=/Users/ambrozic/.pyenv/versions/2.7.14/bin/python

source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
