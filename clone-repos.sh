#!/bin/bash
set -u
set -o pipefail

Source="${1:-Github}"
CurrentRepo="notset"
Location="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" >/dev/null 2>&1 && pwd  )"
echo "Cloning repos in: ${Location}."
export GOBIN=~/go/bin

traperr() {
	echo "ERROR: ${BASH_SOURCE[1]} near line ${BASH_LINENO[0]} while working with ${CurrentRepo}."
}
trap traperr ERR

declare -a CloneRepos=("storj" "gateway-mt" "tardigrade-satellite-theme")

for val in "${CloneRepos[@]}"; do
	CurrentRepo=$val

	if [[ -d "${Location}/${CurrentRepo}" ]]; then
		echo "${CurrentRepo} folder already exists, skipping checkout."
	else
		if [[ "${Source}" == "Github" ]]; then
			echo "Cloning from github..."
			git clone "git@github.com:storj/${CurrentRepo}.git"
		else
			echo "Cloning using gerrit support scripts"
			curl -sSL storj.io/clone | sh -s "${CurrentRepo}"
		fi
	fi

	echo "Installing ${CurrentRepo}..."
	if [[ -d "${Location}/${CurrentRepo}/cmd/" ]]; then
		echo "${CurrentRepo} has cmd directory"
		cd "${Location}/${CurrentRepo}/"
		go install -v ./cmd/...
	else
		echo "${CurrentRepo} doesn't contain a cmd directory."
		# Tardigrade Branding
		# cp -r "${Location}/tardigrade-satellite-theme/europe-west-1/*" "${Location}/storj/web/satellite/"
	fi
done
