############################################
# EXPORTS
############################################
export LANG=en_US.UTF-8
export LDFLAGS="-L/usr/local/opt/libxml2/lib -L/usr/local/opt/lapack/lib -L/usr/local/opt/zlib/lib"
export CPPFLAGS="-I/usr/local/opt/libxml2/include -I/usr/local/opt/lapack/include -I/usr/local/opt/zlib/include"
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad
export HISTCONTROL=ignoreboth:erasedups
export BASH_COMPLETION_COMPAT_DIR="/usr/local/etc/bash_completion.d"

############################################
# BASH AUTOCOMPLETE
############################################
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

############################################
# SAVE BASH HISTORY ON EACH COMMAND
############################################
shopt -s histappend ; PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

############################################
# ALIASES
############################################
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ll="ls -aGlsph"
alias tailfn="tail -f -n 1000"
alias shtop="sudo htop"
alias a="ipythonshell"

############################################
# COLOR VARIABLES
#
# color chart:
#   http://www.calmar.ws/vim/256-xterm-24bit-rgb-color-chart.html
#
############################################
if tput setaf 1 &> /dev/null; then
    tput sgr0
    if [[ $(tput colors) -ge 256 ]] 2>/dev/null; then
        RED="$(tput setaf 1)"
        ORANGE="$(tput setaf 208)"
        GREEN="$(tput setaf 2)"
        YELLOW="$(tput setaf 184)"
        BLUE="$(tput setaf 4)"
        PURPLE="$(tput setaf 5)"
        CYAN="$(tput setaf 6)"
        WHITE="$(tput setaf 7)"
        BG="$(tput setab 17)"
    else
        RED="$(tput setaf 1)"
        ORANGE="$(tput setaf 1)"
        GREEN="$(tput setaf 2)"
        YELLOW="$(tput setaf 3)"
        BLUE="$(tput setaf 4)"
        PURPLE="$(tput setaf 5)"
        CYAN="$(tput setaf 6)"
        WHITE="$(tput setaf 7)"
        BG="$(tput setab 4)"
    fi
    BOLD="$(tput bold)"
    RESET="$(tput sgr0)"
else
    RED="\033[1;31m"
    ORANGE="\033[1;31m"
    GREEN="\033[1;32m"
    YELLOW="\033[1;33m"
    BLUE="\033[1;34m"
    PURPLE="\033[1;35m"
    CYAN="\033[1;36m"
    WHITE="\033[1;37m"
    BOLD=""
    BG=""
    RESET="\033[m"
fi

############################################
# VIRTUAL ENV PROMPT COLORING
############################################
function get_venv_prompt () {
    if [ "$VIRTUAL_ENV" ] ; then
        printf "%s" "\[$CYAN\]env \[$ORANGE\]$(pyenv version-name)\[$RESET\] "
    fi
}

############################################
# GIT PROMPT COLORING
############################################
function get_git_prompt () {
    local s=""
	local color=$GREEN
    local branchName=""

    # check if the current directory is in a git repository
    if [ $(git rev-parse --is-inside-work-tree &>/dev/null; printf "%s" $?) == 0 ]; then

        # get branch name
        branchName="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || git rev-parse --short HEAD 2> /dev/null || printf "(unknown)")"

        # check if the current directory is in .git before running git checks
        if [ "$(git rev-parse --is-inside-git-dir 2> /dev/null)" == "false" ]; then

            # ensure index is up to date
            git update-index --really-refresh  -q &>/dev/null

            # check for stashed files
            if $(git rev-parse --verify refs/stash &>/dev/null); then
                s="\[$PURPLE\]#$s";
                color=$PURPLE;
            fi

            # check for un-tracked files
            if [ $(git status --porcelain 2>/dev/null| grep "^??" | wc -l) != 0 ]; then
                s="\[$CYAN\]?$s";
                color=$CYAN;
            fi

            # check for un-committed changes in the index
            if [ "$(git diff --name-only --staged)" ]; then
                s="\[$BLUE\]+$s";
                color=$BLUE;
            fi

            # check for un-pushed commits
            if [[ $(git branch -v | grep $branchName) =~ ("[ahead "([[:digit:]]*)) ]]; then
                s="\[$YELLOW\]!$s";
                color=$YELLOW;
            fi

            # check for un-staged changes
            if [ "$(git diff --name-only)" ] ; then
                s="\[$RED\]*$s";
                color=$RED;
            fi

        fi

        [ -n "$s" ] && s="\[$RESET\]$s\[$RESET\]"

        printf "%s" "\[$CYAN\]on \[$color\]$branchName$s\[$RESET\] "
    else
        return
    fi
}

############################################
# RENDER PROMPT
############################################
function render_bash_prompt(){
    local prompt=""
    prompt+="\[$ORANGE\]┏╸\[$YELLOW\]\u\[$CYAN\] at \[$YELLOW\]\h\[$RESET\] "
    prompt+="\[$CYAN\]in \[$BLUE\]\w\[$RESET\] "
    prompt+="$(get_venv_prompt)"
    prompt+="$(get_git_prompt)\n"
    prompt+="\[$ORANGE\]┗╸\[$RESET\]"
    export PS1=$prompt
}
export PROMPT_COMMAND=render_bash_prompt

############################################
# VIRTUALENV INFO
############################################
function venv() {
    echo $BLUE" "Version: $GREEN$(python -V || printf '-')$RESET
    echo $BLUE""Location: $GREEN$(pyenv which python || printf '-')$RESET
    echo $BLUE"  "Origin: $GREEN$(pyenv version-origin || printf '-')$RESET
    echo $BLUE" "Virtual: $GREEN${VIRTUAL_ENV:=-}$RESET
}

############################################
# VIRTUALENV GENERATOR
############################################
function xvenv() {
    local versions=( $( pyenv versions --bare --skip-aliases | grep -v / | sed 's/:.*//' ) )
    local length=${#versions[@]}
    if [ $length -eq 0 ]; then
        printf "No pyenv python versions available\n"
        return
    fi

    printf "Available pyenv versions:\n"
    for i in "${!versions[@]}"; do 
        printf "  $BLUE[$GREEN$[$i+1]$BLUE]$RESET $YELLOW${versions[$i]}$RESET\n"
    done

    read -p $"Select number [$GREEN$[$length]$RESET]: " vn
    vn=${vn:-$length}
    if [[ ($vn -lt 1) || ($vn -gt $length) ]] ; then
        printf "Invalid version selected\n"
        return
    fi
    local version=${versions[$[$vn-1]]}

    read -p $"Name [$GREEN${PWD##*/}$RESET]: " name
    name=${name:-${PWD##*/}}

    read -p "Create new virtual environment $GREEN$name$RESET from version $GREEN$version$RESET? [Yn]: " answer
    if [[ ${answer:-Y} != "Y" ]]; then
        printf "Canceled\n"
        return
    fi

    pyenv virtualenv $version $name
    echo $name > .python-version
    echo "Using" $( pyenv version )
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
# GIT REPOSITORY INFO
############################################
function gitinfo() {
    local branchName=""

    # check if the current directory is in a git repository
    if [ $(git rev-parse --is-inside-work-tree &>/dev/null; printf "%s" $?) == 0 ]; then

        # get branch name
        branchName="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || git rev-parse --short HEAD 2> /dev/null || printf "(unknown)")"

        # check if the current directory is in .git before running git checks
        if [ "$(git rev-parse --is-inside-git-dir 2> /dev/null)" == "false" ]; then

            # ensure index is up to date
            git update-index --really-refresh  -q &>/dev/null

            # git repository info
            printf "  %s%-14s %s$RESET\n" "$RED" "* un-staged" "$(git diff --name-only | wc -l)"
            printf "  %s%-14s %s$RESET\n" "$YELLOW" "! un-pushed" "$(git diff $branchName..HEAD | wc -l)"
            printf "  %s%-14s %s$RESET\n" "$BLUE" "+ un-committed" "$(git diff --name-only --staged | wc -l)"
            printf "  %s%-14s %s$RESET\n" "$CYAN" "? un-tracked" "$(git status --porcelain | wc -l)"
            printf "  %s%-14s %s$RESET\n" "$PURPLE" "# stashed" "$(git stash list | wc -l)"

        fi
    else
        echo "Not a git repository"
    fi
}

############################################
# GREP SEARCH
############################################
function search() {

    if [ "$1" == "--help" ] || [ "$1" == "-h" ] || [ "$#" -eq 0 ]
    then
        echo ""
        echo "Usage:"
        echo "  search . term      # finds 'term' in all files"
        echo "  search . term \*   # finds 'term' in all files"
        echo "  search . term .txt # finds 'term' in *.txt files"
        echo "  search . term .\*  # finds 'term' in .* files"
        echo ""
        return
    fi

    local where="$1"
    local what="$2"
    local in="$3"
    
    if [[ "$#" -eq 2 ]]
    then
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

    echo "Finished searching in '$BLUE$where$RESET' for '$GREEN$what$RESET' in '$ORANGE$in$RESET' files";
}

############################################
# CLEAN 
############################################
function clean() {
    find / -name '.DS_Store' -type f -delete
    echo "Removed all '.DS_Store' files";
}

############################################
# IPYTHONSHELL
############################################
function ipythonshell() {
    if hash ipython 2>/dev/null; then
        ipython
    else
        read -p "ipython is missing. Install globally? [yN]: " answer
        if [ $answer = "y" ]; then
            pip install ipython
        fi
    fi
}

############################################
# BACKUP
############################################
function backup() {
    backup=/Users/ambrozic/Dropbox/Backup/
    mkdir -p $backup
    read -p "Dry run first? [nY]: " answer

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
# BREW
############################################
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

############################################
# PYTHON
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
