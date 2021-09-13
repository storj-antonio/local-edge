#!/bin/bash
set -ue
set -o pipefail
set -o errtrace

Source=${1:-Github}
CurrentRepo="notset"
Location="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" >/dev/null 2>&1 && pwd  )"
echo "${Location}"

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
		if [[ "${Source}" == "Github" ]]; then
			git clone "git@github.com:storj/${CurrentRepo}.git"
		else
			curl -sSL storj.io/clone | sh -s "${CurrentRepo}"
		fi
	fi

	echo "Changing directory to ${CurrentRepo}."
	cd "${CurrentRepo}"

	echo "Installing ${CurrentRepo}..."
	if [[ -d "${CurrentRepo}/cmd/" ]]; then
		cd "cmd/"
		go install -v ./cmd/...
		cd "${Location}"
	else
		cd "${Location}"
		# Tardigrade Branding
		cp -r ./tardigrade-satellite-theme/europe-west-1/* ./storj/web/satellite/
		cd ./storj/web/satellite/
		npm install
		npm run build

		# Generate WASM
		cd "${Location}/storj/"
		make satellite-wasm
		mv release/*/wasm/* web/satellite/static/wasm/
	fi
done
