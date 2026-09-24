DISABLE_MAGIC_FUNCTIONS="true"
COMPLETION_WAITING_DOTS="true"

function sesh-sessions() {
  {
    exec </dev/tty
    exec <&1
    sesh picker
    zle reset-prompt > /dev/null 2>&1 || true
  }
}

zle -N sesh-sessions
bindkey -M emacs '\es' sesh-sessions
bindkey -M vicmd '\es' sesh-sessions
bindkey -M viins '\es' sesh-sessions

if command -v tmux >/dev/null 2>&1 && [ -z "$TMUX" ]; then
  if ! tmux ls >/dev/null 2>&1; then
    exec tmux new-session -s main
  fi
fi

() {
  local -a opts
  opts=(${(z)FZF_DEFAULT_OPTS})
  opts=("${(@)opts:#--color=*}")
  export FZF_DEFAULT_OPTS="${(j: :)opts}${opts:+ }--color=base16,fg:-1,bg:-1,preview-fg:-1,preview-bg:-1"
}



