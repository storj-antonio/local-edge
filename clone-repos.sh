#!/bin/bash
set -ue
set -o pipefail
set -o errtrace

CurrentRepo="notset"

# [ $# -eq 0  ] && { echo "Usage: $0 -- Just call the script for now."; exit 1;  }

traperr() {
	echo "ERROR: ${BASH_SOURCE[1]} near line ${BASH_LINENO[0]} while working with ${CurrentRepo}."
}
trap traperr ERR

declare -a CloneRepos=("storj" "gateway-mt" "tardigrade-satellite-theme")

for val in "${CloneRepos[@]}"; do
	CurrentRepo=$val
	if [[ -d "./${CurrentRepo}" ]]; then
		echo "${CurrentRepo} folder already exists, skipping checkout."
	else
		echo "Cloning Repo - ${CurrentRepo}"
		git clone "git@github.com:storj/${CurrentRepo}.git"
	fi

	echo "Changing directory to ${CurrentRepo}."
	cd "${CurrentRepo}"
	echo "Installing ${CurrentRepo}..."
	if [[ -d "${CurrentRepo}/cmd/" ]]; then
		cd "cmd/"
		go install -v ./cmd/...
	fi

done
