#!/bin/bash
set -ue
set -o pipefail

export PATH=$PATH:$HOME/go/bin

traperr() {
	echo "ERROR: ${BASH_SOURCE[1]} near line ${BASH_LINENO[0]} while working with ${CurrentFolder}."
	echo "Kill Services..."
	# trap 'pkill -P $$' SIGINT SIGTERM EXIT <---- Try this one at a later time. This guy kills all subprocesses.
	for value in "${serv_pid[@]}"; do
		kill value
	done
}
trap traperr SIGINT SIGTERM EXIT

declare -A serv_pid
serv_pid[cockroach]="${!}"

