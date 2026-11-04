set -g fish_greeting

set -x LESS -R

if command -v nvim &>/dev/null
    set -x EDITOR nvim
end

if command -v ghostty &>/dev/null
    set -x TERMINAL ghostty
end

if command -v session &>/dev/null
    bind ctrl-s session
end

set -x QT_QPA_PLATFORMTHEME gtk3

if test -e "$HOME/.local/scripts"
    fish_add_path "$HOME/.local/scripts"
end

bind ctrl-space accept-autosuggestion

alias clear "clear -x"
alias sail "sh $([ -f sail ] && echo sail || echo vendor/bin/sail)"
alias git-log-pretty "git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)'"

abbr --add gn "git reset --hard HEAD && git clean -fd"
abbr --add gac "git add -A && git commit -m"
abbr --add ga "git add -A && git commit --amend"

if test "$TERM" = dumb
    exit 0
end

if command -v zoxide &>/dev/null
    zoxide init fish | source
end

if command -v starship &>/dev/null
    starship init fish | source
end

if command -v fzf &>/dev/null
    set -x FZF_DEFAULT_OPTS '
      --color=fg:#d0d0d0,fg+:#d0d0d0
      --color=hl:#6db760,hl+:#ff9c5e,info:#afaf87,marker:#6db760
      --color=prompt:#cd9bff,spinner:#ff48ad,pointer:#cd9bff,header:#87afaf
      --color=border:#262626,label:#aeaeae,query:#d9d9d9
      --prompt="> " --marker=">" --pointer="◆" --separator="─" --scrollbar="│"'
    fzf --fish | source
end

function nix_shell_on_variable_pwd --on-variable PWD
    if test -n "$DISABLE_NIX_SHELL_ON_CD"
        return
    end
    if command -v nix &>/dev/null && test -f "flake.nix" && test -z "$IN_NIX_SHELL" && grep devShells "$PWD/flake.nix" &>/dev/null
        nix develop --command fish
    end
end

nix_shell_on_variable_pwd
