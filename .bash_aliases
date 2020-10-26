# shellcheck shell=bash
unalias -a

[ "$TERM_PROGRAM" = "vscode" ] && alias nano="code -w"

# === Aliases
#
# --- Manage aliases
alias edit-aliases='nano ~/.bash_aliases && shellcheck ~/.bash_aliases && source ~/.bash_aliases'
alias list-aliases='cat ~/.bash_aliases | grep -E "^(alias|#)" --color=never | grep -v "alias __" --color=never'
#
# --- Common helpers
alias now='date +"%Y-%m-%d-%H-%M-%S"'
alias mit='curl -s https://4ops.mit-license.org/license.txt'
alias myip='export MYIP="$(curl -s https://api.ipify.org)" ; echo "$MYIP"'
alias printenv='printenv | sort | grep -v -E "^__\w"'
alias mkpass='export PASSWORD_LENGTH="${PASSWORD_LENGTH:-32}" ; cat /dev/urandom | tr -dc a-zA-Z0-9 | fold -w "${PASSWORD_LENGTH}" | head -n 1'
#
# --- Filesystem
alias ..='cd ..'
alias ...='cd ../..'
alias cd..='cd ..'
alias ll='ls -lA'
alias la='ls -lA'
alias df='df -h | grep -E -v "^/dev/loop|^tmpfs|^udev"'
alias tmp='cd $(mktemp -d)'
alias backup-dir='export BACKUP_PWD="$(pwd).$(now).backup" && cp -r "$(pwd)" "$BACKUP_PWD" && du -hs "$(pwd)" "$BACKUP_PWD"'
alias restore-dir='test -n "$BACKUP_PWD" && test -d "$BACKUP_PWD" && export RESTORE_PWD="$(pwd)" && cd /tmp && rm -rf "$RESTORE_PWD" && cp -r "$BACKUP_PWD" "$RESTORE_PWD" && cd "$RESTORE_PWD" && du -hs "$BACKUP_PWD" "$RESTORE_PWD"'
#
# --- Other system tools
alias ppp='ps -auxZ | less'
alias sss='ss -lntup'
alias update-all='sudo apt update && sudo apt upgrade -y --no-install-recommends && sudo apt autoremove -y && sudo apt autoclean -y'
#
# --- Docker containers
alias alpine='docker run --rm -it alpine:3.12 ; echo'
alias bbox='docker run --volume "$(pwd):$(pwd)" --workdir "$(pwd)" --user "$(id --user)" --rm -it busybox:1.31 sh ; echo'
alias drun='docker run --rm -it'
alias build-image='export TEST_IMAGE=$(basename $(pwd) | tr [:upper:] [:lower:] | tr -d "_.~@ +") && docker build . --tag $TEST_IMAGE'
alias test-image='test -n "$TEST_IMAGE" || build-image && docker run --rm -it --publish-all "$TEST_IMAGE"'
#
# --- Git
alias g='git status --short'
alias gg='git status --long'
alias gh='git log --oneline --simplify-by-decoration --reverse'
alias aa='git rev-parse --show-toplevel > /dev/null && $(cd "$(git rev-parse --show-toplevel)" && git add --all .)'
alias fixup='git commit --fixup=$(git log --grep="^fixup! " --invert-grep --max-count=1 --format=format:%H | grep -v "^gpg")'
alias git-create='test -n "$PROJECT_NAME" && mkdir "$PROJECT_NAME" && cd "$PROJECT_NAME" && git clone git@github.com:4ops/template.git . && make init'
