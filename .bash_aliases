# shellcheck shell=bash
# shellcheck disable=SC1090,SC2006,SC2015

unalias -a

declare -i use_shellcheck=0

if type -p shellcheck > /dev/null; then
	use_shellcheck=1
fi

ERROR() {
	echo "$*" >&2
}

editor() {
	"${EDITOR:-nano}" "$@"
}

shellcheck() {
	if [ $use_shellcheck -ne 1 ]; then
		return 0
	fi
	command shellcheck "$@"
}

__start_minikube() {
	if ! minikube start; then
		ERROR "Failed to start minikube"
		return 1
	fi

	__minikube_ip=$(minikube ip)

	if [ -z "$__minikube_ip" ]; then
		ERROR "Failed to discover IP address of the minikube node"
		return 1
	fi

	minikube addons enable metrics-server
	minikube addons enable dashboard
	kubectl create ns monitoring

	for resource in \
		alertmanager \
		podmonitor \
		probe \
		prometheus \
		prometheusrules \
		servicemonitor \
		thanosrulers \
	;\
		do kubectl apply -f "https://raw.githubusercontent.com/prometheus-community/helm-charts/main/charts/kube-prometheus-stack/crds/crd-${resource}.yaml"
	done
}

if [ "$XDG_SESSION_TYPE" = "x11" ]; then
	export EDITOR="code -w"
fi

if [ "$TERM_PROGRAM" = "vscode" ]; then
	alias yes='echo "Try command \"y\" or remember what you are trying to do"'
	alias nano="code -w"
fi

# === Aliases
#
# --- Manage aliases
alias edit-aliases='editor ~/.bash_aliases && shellcheck ~/.bash_aliases && source ~/.bash_aliases && test -f ~/.bash_aliases_private && source ~/.bash_aliases_private'
alias list-aliases='cat ~/.bash_aliases | grep -E "^(alias|#)" --color=never | grep -v "alias __" --color=never ; test -f ~/.bash_aliases_private && cat ~/.bash_aliases_private'
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
alias ff='find . -type f -name'
alias df='df -h | grep -E -v "^/dev/loop|^tmpfs|^udev"'
alias tmp='cd $(mktemp -d)'
alias backup-dir='export BACKUP_PWD="$(pwd).$(now).backup" && cp -r "$(pwd)" "$BACKUP_PWD" && du -hs "$(pwd)" "$BACKUP_PWD"'
alias restore-dir='test -n "$BACKUP_PWD" && test -d "$BACKUP_PWD" && export RESTORE_PWD="$(pwd)" && cd /tmp && rm -rf "$RESTORE_PWD" && cp -r "$BACKUP_PWD" "$RESTORE_PWD" && cd "$RESTORE_PWD" && du -hs "$BACKUP_PWD" "$RESTORE_PWD"'
#
# --- Docker containers
alias alpine='docker run --rm -it alpine:3.12 ; echo'
alias bbox='docker run --volume "$(pwd):$(pwd)" --workdir "$(pwd)" --user "$(id --user)" --rm -it busybox:1.32 sh ; echo'
alias ami='docker run --volume "$(pwd):$(pwd)" --workdir "$(pwd)" --rm -it amazonlinux:latest'
alias drun='docker run --rm -it'
alias build-image='export TEST_IMAGE=$(basename $(pwd) | tr [:upper:] [:lower:] | tr -d "_.~@ +") && docker build . --tag $TEST_IMAGE'
alias test-image='test -n "$TEST_IMAGE" || build-image && docker run --rm -it --publish-all "$TEST_IMAGE"'
#
# --- Kubernetes
alias k=kubectl
complete -F __start_kubectl k
alias start-minikube='__start_minikube'
alias new-minikube='minikube delete ; docker rm minikube 2>/dev/null ; start-minikube'
alias no='kubectl get no --label-columns="tier,node.kubernetes.io/instance-type,topology.kubernetes.io/zone"'
alias pods='kubectl get po --label-columns="app.kubernetes.io/name,app.kubernetes.io/instance,app"'
alias watch-pods='watch -c -n3 kubectl get po --label-columns="app.kubernetes.io/name,app.kubernetes.io/instance,app"'
alias deployments='kubectl get deployments --label-columns="app.kubernetes.io/name,app.kubernetes.io/instance,app.kubernetes.io/version,app"'
alias remove-failed-pods='kubectl delete po --all-namespaces --field-selector="status.phase=Failed"'
alias run-k8s-pod='kubectl -n kube-system run --rm -it --image=alpine:3.12 test -- sh'
alias promdash='kubectl -n monitoring port-forward service/prometheus-operated 9090'
#
# --- Git
alias g='git status --short'
alias gg='git status --long'
alias gh='git log --oneline --simplify-by-decoration'
alias aa='git rev-parse --show-toplevel > /dev/null && $(cd "$(git rev-parse --show-toplevel)" && git add --all .)'
alias hh='test -f Chart.yaml && helm-docs && helm schema-gen values.yaml > values.schema.json'
alias fixup='git commit --fixup=$(git log --grep="^fixup! " --invert-grep --max-count=1 --format=format:%H | grep -v "^gpg")'
alias push-release='git checkout develop && git push -u origin develop -o ci.skip && git checkout master && git push -o ci.skip && git push --tags'
alias git-create='test -n "$PROJECT_NAME" && mkdir "$PROJECT_NAME" && cd "$PROJECT_NAME" && git clone git@github.com:4ops/template.git . && rm -rf .git && curl -s https://4ops.mit-license.org/license.txt > LICENSE && git add -A && git commit -m "Initial commit"'
alias git-protonmail='git config --local user.name "Anton Kulikov" && git config --local user.email "anton.kulikov@protonmail.com"'
#
# --- Terraform
alias tfinit='source secrets.env && terraform init && terraform plan -out plan.tfplan'
alias tfapply='terraform apply plan.tfplan ; rm -f plan.tfplan'
#
# --- Other system tools
alias ppp='ps -auxZ | less'
alias sss='ss -lntup'
alias update-all='sudo apt update && sudo apt upgrade -y --no-install-recommends && sudo apt autoremove -y && sudo apt autoclean -y'
alias clean-all='docker system prune --all --force --volumes ; sudo rm -rf /tmp/.*  /tmp/* /var/tmp/.* /var/tmp/*'

# Load priavte aliases
test -f ~/.bash_aliases_private \
	&& source ~/.bash_aliases_private \
	|| true
