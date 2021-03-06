#!/bin/bash
set -ue
set -o pipefail

trap traperr err
traperr() {
	echo "ERROR: ${BASH_SOURCE[1]} near line ${BASH_LINENO[0]}."
	'pkill -P $$'
}

# This works with a basic top down approach, and also literally from the top down.
# If we catch the clean optional arguement we will clean and then fall directly
# into a clone.
# But seriously i would modify the call to clone repo to include the -e arguement.
# That will clone the repos using gerrit support scripts.

while getopts "c" arg; do
	# I know a case statement is overkill atm but it will be needed later.
	case $arg in
		c)
			./clean-project.sh -a
			;;
	esac
done

source ./clone-repos.sh&&
source ./build-web.sh&&
source ./start-services.sh&&
source ./run-ui.sh
