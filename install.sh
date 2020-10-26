#!/usr/bin/env bash
# shellcheck disable=SC2034

set -o pipefail
set -o errtrace
set -o nounset
set -o errexit

declare -i use_shellcheck=0

if [ ! -d .git ]; then
	echo "Not in git repository" >&2
	exit 1
fi

if type -p shellcheck > /dev/null; then
	use_shellcheck=1
fi

for src in .bash_aliases .bashrc .git-prompt.sh .profile; do
	[ $use_shellcheck -ne 1 ] || shellcheck --exclude=SC2148 $src
	cp -f "$(pwd)/${src}" "${HOME}/${src}"
done
