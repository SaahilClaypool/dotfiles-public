function src {
    [ -f $1 ] && source $1
}

src ~/.config/short_path.sh
src ~/.config/secrets.sh

function install {
    if [ -x $1 ]; then
        eval $2
    fi
    eval $3
}

# DOCKER_SOCK="/mnt/wsl/shared-docker/docker.sock"
# test -S "$DOCKER_SOCK" && export DOCKER_HOST="unix://$DOCKER_SOCK"

export PATH="$HOME/.local/bin:$PATH"
export DOTNET_ROOT=$HOME/.dotnet
export PATH="$DOTNET_ROOT:$PATH"
export PATH="$HOME/.dotnet/tools:$PATH"
export PATH=~/.local/bin/:$PATH
export PATH=~/dotfiles/bin/:$PATH
export PATH=~/dotfiles-public/bin/:$PATH
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="/snap/bin:$PATH"
export PATH="$HOME/.gem/ruby/2.5.0/bin:$PATH"
export EDITOR="nvim"

[ -x /home/linuxbrew/.linuxbrew/bin/brew ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

function import-env {
    f=".env"
    if [ -z "$1" ]; then
    else
        f=$1
    fi
    echo Loading $f
    # Local .env
    if [ -f $f ]; then
        set -o allexport; source $f; set +o allexport
    fi
}

export ZSH_DISABLE_COMPFIX=true
DIRSTACKSIZE=8
setopt autopushd pushdminus pushdsilent pushdtohome

if [ ! -f ~/.zgen/zgen.zsh ]; then
    git clone https://github.com/tarjoilija/zgen.git "${HOME}/.zgen"
fi

src "${HOME}/.zgen/zgen.zsh"

# if the init script doesn't exist
if ! zgen saved; then
    echo "reloading packages"

  # specify plugins here
  zgen oh-my-zsh
  zgen oh-my-zsh plugins/gitfast
  zgen oh-my-zsh plugins/tmux
  zgen oh-my-zsh plugins/fancy-ctrl-z
  zgen oh-my-zsh plugins/fzf
  zgen oh-my-zsh plugins/aws
  zgen oh-my-zsh plugins/gitignore
  zgen oh-my-zsh plugins/rust
  zgen load zsh-users/zsh-completions
  zgen oh-my-zsh plugins/docker
  zgen oh-my-zsh plugins/docker-compose

  src ~/.config/local_plugins.zsh
  zgen save
fi
[ -x "$(command -v zoxide)" ] && eval "$(zoxide init zsh)"


bindkey '^i' complete-word


# reload tmux env every command...
if [ -n "$TMUX" ]; then
  function refresh {
    export $(tmux show-environment | grep "^SSH_AUTH_SOCK") > /dev/null
    export $(tmux show-environment | grep "^DISPLAY") > /dev/null
    # export $(tmux show-environment | grep "^SSH_CONNECTION") > /dev/null
    export $(tmux show-environment | grep "^VSCODE_IPC_HOOK_CLI") > /dev/null
    export "$(tmux show-environment | grep "^PATH")" > /dev/null
  }
else
  function refresh {  
    echo "" > /dev/null
  }
fi


export ZSH_AUTOSUGGEST_USE_ASYNC=1
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#bbbbbb"
export ZSH_AUTOSUGGEST_STRATEGY=('completion')

export DISABLE_MAGIC_FUNCTIONS=true
export REVIEW_BASE="origin/develop"


SOBOLE_THEME_MODE=light
source $HOME/dotfiles-public/theme.zsh

alias lll="ls -lrtah"
alias j="z"
function open {
    xdg-open $@ > /dev/null 2>&1;
}
alias o='open'
alias sssh="ssh -XR 2222:127.0.0.1:22"
alias vim=nvim
alias np="VIM_PLUGINS='true' nvim"
alias n="nvim"
alias e=$EDITOR
alias c=code
alias g=git
alias tldr=~/dotfiles/tldr
setopt globdots

function safe_rm {
    [ ! -d "~/.trash" ] && mkdir ~/.trash > /dev/null 2>&1;
    mv -f $@ ~/.trash
}

function backup_trash {
    [ ! -d "~/.old_trash" ] && mkdir ~/.old_trash > /dev/null 2>&1;
    /bin/rm -rf ~/.old_trash/*
    mv -f ~/.trash/* ~/.old_trash/
}

alias rm=safe_rm
alias dump=backup_trash

function gd {
    echo $@
    git diff `git merge-base --octopus origin/develop` $@
}

function gmb {
    branch="origin/develop"
    if (( $# >= 1 )); then
        branch=${1};
    fi;
    git show-branch --merge-base `git rev-parse --abbrev-ref HEAD` $branch | xsel --clipboard;
    xsel --clipboard --output;
    export REVIEW_BASE=`xsel --clipboard --output`
}

function gundo {
    read "undo?undo last commit?"
    if [[ $undo =~ ^[Yy]$ ]]
    then
        git reset --soft HEAD~
        echo "Undid last commit - changes in working directory"
    fi
}

function rrsync {
    if [ -f './.rsyncignore' ]; then
        rsync -avzP --compress --exclude-from=./.rsyncignore --exclude-from=$HOME/dotfiles/rsyncignore -e ssh $@
    else
        rsync -avzP --compress --exclude-from=$HOME/dotfiles/rsyncignore -e ssh $@
    fi
}

function rrsync_watch {
    echo "Watching and syncing `pwd` --> $@"
    inotifywait -r -e modify,create,delete,move . -m \
    | while read; do
        rrsync . $@
    done
}

function sscp {
    rsync -vR -e "ssh -p 2222" $argv localhost:~/Sync
}
# Add margins to a pdf for note taking
function pdfnote {
    python3 -m pdfCropMargins --samePageSize --uniform -su original --queryModifyOriginal \
        -p 0 -a4 -30 -200 -200 -10 \
        $argv;
}

function root {
    gitroot="$(git rev-parse --show-toplevel)" 2> /dev/null
    rc=$?;
    if [ $gitroot ]; then
        echo $(basename $gitroot);
        return $(basename $gitroot);
    fi

    echo $(basename `pwd`);
    return $(basename `pwd`);
}

if [ -x  "$(command -v tectonic)" ]; then
    if [ -x "$(command -v mermaid-filter)" ]; then
        function pandoc {
            /usr/bin/pandoc -F mermaid-filter --pdf-engine=tectonic $@
        }
    else
        function pandoc {
            /usr/bin/pandoc --pdf-engine=tectonic $@
        }
    fi
elif [ -x "$(command -v docker)" ]; then
    function pandoc {
        docker run --rm --volume `pwd`:/data --user `id -u`:`id -g` pandoc/latex $@
    }
fi

function pandocd {
    if [ "$#" -eq 0 ]; then
        echo "usage: ppandoc <input> [output_extension]"
        return;
    fi;
    input=$1;
    # shift consumes the argument
    shift
    filename=${input%.*};
    output=${filename}.pdf;
    if (( $# >= 1 )); then
        output=${filename}.${1};
        shift
    fi;
    echo "converting $input to $output -- $argv"
    echo "pandoc -o $output $input --standalone --self-contained -V fontsize=11pt -V geometry:'margin=0.75in' --variable urlcolor=blue --from markdown+implicit_figures $argv"
    pandoc -o $output $input --standalone --self-contained -V fontsize=11pt -V geometry:"margin=0.75in" --variable urlcolor=blue --from markdown+implicit_figures $argv
}

# fzf config
 _gen_fzf_default_opts() {
  local base03="234"
  local base02="235"
  local base01="240"
  local base00="241"
  local base0="244"
  local base1="245"
  local base2="254"
  local base3="230"
  local yellow="136"
  local orange="166"
  local red="160"
  local magenta="125"
  local violet="61"
  local blue="33" 
  local cyan="37"
  local green="64"

  # Comment and uncomment below for the light theme.

  ## Solarized Dark color scheme for fzf
  #export FZF_DEFAULT_OPTS="
    #--color fg:-1,bg:-1,hl:$blue,fg+:$base2,bg+:$base02,hl+:$blue
    #--color info:$yellow,prompt:$yellow,pointer:$base3,marker:$base3,spinner:$yellow
  #"
  # Solarized Light color scheme for fzf
  export FZF_DEFAULT_OPTS="
    --color fg:-1,bg:-1,hl:$blue,fg+:$base02,bg+:$base2,hl+:$blue
    --color info:$yellow,prompt:$yellow,pointer:$base03,marker:$base03,spinner:$yellow
  "
}
_gen_fzf_default_opts
if [ -x "$(command -v rg)" ]; then
    function FZF_NOIGNORE {
        export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*" --no-messages '
    }
    function FZF_IGNORE {
        export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git/*" --no-messages '
    }
    FZF_IGNORE
fi

if [ -x "$(command -v fd)" ]; then
    export FZF_DEFAULT_COMMAND="fd --type file"
    export FZF_DEFAULT_OPTS="--ansi"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

if [ -x "$(command -v bat)" ]; then
    export FZF_CTRL_T_OPTS="--ansi --preview-window 'right:60%' --preview 'bat --theme='ansi-light' --color=always --style=header,grid --line-range :300 {}'"

    export BAT_CONFIG_PATH="~/dotfiles/.bat.conf"
    alias bat="bat --theme='ansi-light'"
    alias cat=bat

fi

fix_wsl2_interop() {
    for i in $(pstree -np -s $$ | grep -o -E '[0-9]+'); do
        if [[ -e "/run/WSL/${i}_interop" ]]; then
            export WSL_INTEROP=/run/WSL/${i}_interop
        fi
    done
}
fix_wsl2_interop

# https://www.mervine.net/hacks/zsh-known-hosts-completion
[ ! -f ~/.ssh/config ] && echo "HashKnownHosts no\n" > ~/.ssh/config && echo "TODO: remove hashed ~/.ssh/known_hosts"
local knownhosts
knownhosts=( ${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[0-9]*}%%\ *}%%,*} )
zstyle ':completion:*:(ssh|scp|sftp):*' hosts $knownhosts

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
setopt HIST_BEEP                 # Beep when accessing nonexistent history.

export SUDO_ASKPASS=/usr/bin/ssh-askpass
export JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")

# git clone https://github.com/nodenv/nodenv.git ~/.nodenv
# cd ~/.nodenv && src/configure && make -C src
# mkdir -p "$(nodenv root)"/plugins
# git clone https://github.com/nodenv/node-build.git "$(nodenv root)"/plugins/node-build
if [ -d ~/.nodenv/ ]; then
    export PATH="$HOME/.nodenv/bin:$PATH"
    eval "$(nodenv init -)"
fi

# git clone https://github.com/rbenv/rbenv.git ~/.rbenv
if  [ -d ~/.rbenv/ ]; then
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
fi

# git clone https://github.com/pyenv/pyenv.git ~/.pyenv
if [ -d ~/.pyenv ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$HOME/.pyenv/bin:$PATH"
    eval "$(pyenv init -)"
fi

# git clone https://github.com/nodenv/nodenv.git ~/.nodenv
# mkdir -p "$(nodenv root)"/plugins
# git clone https://github.com/nodenv/node-build.git "$(nodenv root)"/plugins/node-build
if [ -d ~/.pyenv ]; then
    export NODENV_ROOT="$HOME/.nodenv"
    export PATH="$HOME/.nodenv/bin:$PATH"
    eval "$(nodenv init -)"
fi


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

unsetopt BG_NICE
export TERM=xterm-256color

src ~/.config/local.zsh

import-env

function ,dnr {
    dotnet build --no-restore && dotnet run --project Tasks --no-build -- $@
}

function ,dnw {
    dotnet build && dotnet watch --project server -- $@
}

function ,dnt {
    dotnet build --no-restore && dotnet test --no-build $@
}

function ,gfmt {
    dotnet format && git add -A && git commit -m "fix formatting" && git push
}
