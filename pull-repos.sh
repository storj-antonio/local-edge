#!/bin/bash
set -ue
set -o pipefail

CurrentRepo="notset"

traperr() {
	echo "ERROR: ${BASH_SOURCE[1]} near line ${BASH_LINENO[0]} while working with ${CurrentRepo}."
}

declare -a CloneRepos=("storj" "gateway-mt" "tardigrade-satellite-theme")

for val in "${CloneRepos[@]}"; do
	CurrentRepo=$val
	echo "$CurrentRepo"
	git clone "git@github.com:storj/${CurrentRepo}.git"
done
