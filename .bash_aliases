export __BASH_ALIASES=$HOME/.bash_aliases
export __BASH_ALIASES_WIP=$HOME/.bash_aliases.wip.sh
export __GITHUB_BASE=https://raw.githubusercontent.com/4ops/.dotfiles/master/.github/public
test -d "${HOME}/.git" && echo .git || true
test -f "${__BASH_ALIASES_WIP}" && basename "${__BASH_ALIASES_WIP}" || true
#
if [ "${TERM_PROGRAM}" = "vscode" ]; then
  test -n "${EDITOR}" || export EDITOR="code -w"
else
  test -n "${EDITOR}" || export EDITOR=nano
fi

# Help
alias hh='cat "${__BASH_ALIASES}" | grep -E "^alias\b" --color=never | sed -E "s/^alias //"'
alias hhh='cat "${__BASH_ALIASES}" | grep -E "^$|^# [A-Z]|^alias [a-z.]|^  alias\b" --color=never'

# Utils
alias tmp='cd "$( mktemp -d )"'
  alias __ts='export TS="$( date +"%Y%m%d%H%M%S" )"'
alias backup-dir='__ts ; cp -r "${PWD}" "${PWD}.backup-${TS}" && du -hs "${PWD}" "${PWD}.backup-${TS}" && echo success'
alias update-all='sudo apt update ; sudo apt upgrade -y ; sudo apt autoremove -y ; sudo apt autoclean -y'

# Prettify system tools output
alias printenv='printenv | sort | grep -v -E "^__\w"'
alias ..='cd ..'
alias ...='cd ../..'
alias ll='ls -la'
alias pp='ps -au'
alias ppp='ps -auxZ | less'
alias sss='ss -lntup'
alias df='df -h | grep -E -v "^/dev/loop|^tmpfs|^udev"'
alias du='du -h'

# Docker / TODO: useful dockerfiles ?
alias alpine='docker run --rm -it alpine:3.10'
alias pyth='docker run --rm -it python:3.7-alpine'
  alias __docker_run='docker run --rm -it $TAG'
  alias __docker_build='docker build . -t $TAG -f $DOCKERFILE $DOCKER_ARGS'
  alias __docker_env='test -n "${DOCKERFILE}" || export DOCKERFILE=Dockerfile ; test -n "${TAG}" || export TAG="$( basename "$( pwd )" )"'
  alias __docker_args='test -z "${TARGET}" || export DOCKER_ARGS="--target=${TARGET}"'
alias ddd='__docker_env && __docker_args && __docker_build && __docker_run'

# Kubernetes / TODO: templating ?
alias k8s-deployment='curl -fsSL "${__GITHUB_BASE}/k8s/deployment.yaml"'
alias k8s-service='curl -fsSL "${__GITHUB_BASE}/k8s/service.yaml"'
alias k8s-endpoints='curl -fsSL "${__GITHUB_BASE}/k8s/endpoints.yaml"'
alias k8s-ingress='curl -fsSL "${__GITHUB_BASE}/k8s/ingress.yaml"'
alias k8s-statefulset='curl -fsSL "${__GITHUB_BASE}/k8s/statefulset.yaml"'
alias k8s-kustomization='curl -fsSL "${__GITHUB_BASE}/k8s/kustomization.yaml"'
alias pod-alpine='kubectl run --rm -it --restart=Never --image=alpine:3.10 sh'
alias kk='kubectl apply --dry-run -k'
alias kkk='kubectl kustomize'

# Aliases management
alias rr='reload-aliases'
alias reset-aliases='unalias -a'
alias reload-aliases='test -f "${__BASH_ALIASES_WIP}" && source "${__BASH_ALIASES_WIP}" && echo wip success || source "${__BASH_ALIASES}"'
alias eee='edit-aliases'
alias edit-aliases='test -f "${__BASH_ALIASES_WIP}" || cp -v "${__BASH_ALIASES}" "${__BASH_ALIASES_WIP}" && $EDITOR "${__BASH_ALIASES_WIP}" && reload-aliases'
alias save-aliases='source "${__BASH_ALIASES_WIP}" && __ts && cp -v "${__BASH_ALIASES}" "${__BASH_ALIASES}.backup-${TS}" && cp -vf "${__BASH_ALIASES_WIP}" "${__BASH_ALIASES}" && rm -f "${__BASH_ALIASES_WIP}" && enable-dotfiles-git && pushd "${HOME}" && aa ; popd'

# Home directory .files
alias enable-dotfiles-git='mv -vf "${HOME}/.git-dotfiles-disabled" "${HOME}/.git" && g'
alias disable-dotfiles-git='mv -vf "${HOME}/.git" "${HOME}/.git-dotfiles-disabled"'

# Git / TODO: Update license template
alias mit='wget -q ${__GITHUB_BASE}/LICENSE -O -'
alias gh='git history'
alias gh3='git history --max-count=3'
alias gh5='git history --max-count=5'
alias g='git status --short --branch'
alias gg='git status --long'
alias ggg='git log --oneline --simplify-by-decoration --reverse --max-count 3'
  alias __git_back='test -n "${__CWD}" && cd "${__CWD}" && export -n __CWD'
  alias __git_root='__git_back ; export __CWD="$( pwd )" && git rev-parse --show-toplevel &> /dev/null && cd "$( git rev-parse --show-toplevel )"'
alias aa='__git_root && git add --all . && __git_back'
alias ccc='git commit -m'
alias gu='git pull --rebase'
alias gr='__git_root && git checkout -- . ; __git_back && git checkout master && git pull --rebase'
alias grr='git reset --hard --quiet && git clean -df && gr'
  alias __git_branch='export GIT_CURRENT_BRANCH="$( git branch | grep \* | cut -d " " -f2 )" && test -n "${GIT_CURRENT_BRANCH}"'
alias gp='__git_branch ; git push || git push --set-upstream origin "${GIT_CURRENT_BRANCH}"'
  alias __git_author='export GIT_AUTHOR="$( git config --get user.email )" && test -n "${GIT_AUTHOR}"'
  alias __git_fixup_parent='export GIT_FIXUP_PARENT="$( git log --author="${GIT_AUTHOR}" --grep="^fixup! " --invert-grep --max-count=1 --format=format:%H | grep -v "^gpg" )" && test -n "${GIT_FIXUP_PARENT}"'
alias fixup='__git_author && __git_fixup_parent && git commit --fixup=${GIT_FIXUP_PARENT}'
alias fff='__git_root && aa && fixup && gp && __git_back'

# Git repo helpers
alias create-editorconfig='test -r .editorconfig || curl -fsSL "${__GITHUB_BASE}/.editorconfig" > .editorconfig'
  alias __git_project_name='test -n "${__GIT_PROJECT_NAME}" || export __GIT_PROJECT_NAME="$( basename "$( pwd )" )"'
alias create-readme='__git_project_name && test ! -f README.md && echo -e "# ${__GIT_PROJECT_NAME^}" > README.md && export -n __GIT_PROJECT_NAME'
alias init-repo='__git_root ; git init ; test -r LICENSE || mit > LICENSE ; create-editorconfig ; create-readme ; g'
