CARET_SIGN="❯"
PROMPT='$(_user_host)$(current_dir)
%B%(?.%{$fg[black]%}.%{$fg[red]%})$CARET_SIGN%{$reset_color%} '

PROMPT2='. '

RPROMPT='$(date +"%H:%M:%S")'

setopt promptsubst

function current_dir {
    color=blue
  echo "%{$fg_bold[$color]%}%~%{$reset_color%} "
}

function _user_host() {
  # me="%n@%m"
  color="cyan"
  if [[ -n $SSH_CONNECTION ]]; then
    me="%n@%m"
    color="blue"
    # me="ssh:$me"
  fi
  if [[ -n $HOST_COLOR ]]; then
    color="$HOST_COLOR"
  fi
  if [[ -n $me ]]; then
    echo "%{$fg[$color]%}$me%{$reset_color%}:"
  fi
}

# ----------------------------------------------------------------------------
# `ls` colors
# Made with: http://geoff.greer.fm/lscolors/
# ----------------------------------------------------------------------------

if [[ "$SOBOLE_THEME_MODE" == "dark" ]]; then
  export LSCOLORS="gxfxcxdxbxegedabagacad"
  export LS_COLORS="di=36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
else
  export LSCOLORS="exfxcxdxBxegedabagacab"
  export LS_COLORS="di=34:ln=35:so=32:pi=33:ex=1;31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;41"
fi

# Turns on colors with default unix `ls` command:
export CLICOLOR=1

# ----------------------------------------------------------------------------
# `grep` colors and options
# ----------------------------------------------------------------------------

export GREP_COLOR='1;35'

# ----------------------------------------------------------------------------
# `zstyle` colors
# Internal zsh styles: completions, suggestions, etc
# ----------------------------------------------------------------------------

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:descriptions' format "%B--- %d%b"

# ----------------------------------------------------------------------------
# zsh-syntax-highlighting tweaks
# This setting works only unless `$SOBOLE_DONOTTOUCH_HIGHLIGHTING`
# is set. Any value is fine. For exmaple, you can set it to `true`.
# Anyway, it will only take effect if `zsh-syntax-highlighting`
# is installed, otherwise it does nothing.
# ----------------------------------------------------------------------------

if [[ -z "$SOBOLE_DONOTTOUCH_HIGHLIGHTING" ]]; then
  typeset -A ZSH_HIGHLIGHT_STYLES

  # Disable strings highlighting:
  ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='none'
  ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='none'

  if [[ "$SOBOLE_THEME_MODE" == "dark" ]]; then
    ZSH_HIGHLIGHT_STYLES[path]='fg=white,underline'
  fi
fi
