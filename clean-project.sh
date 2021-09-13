#!/bin/bash
set -ue
set -o pipefail
set -o errtrace

CurrentFolder="notset"

traperr() {
	echo "ERROR: ${BASH_SOURCE[1]} near line ${BASH_LINENO[0]} while working with ${CurrentFolder}."
}
trap traperr ERR

declare -a Folders=("storj" "gateway-mt" "tardigrade-satellite-theme")

for val in "${Folders[@]}"; do
	CurrentFolder=$val
	if [[ -d "./${CurrentFolder}" ]]; then
		echo "Folder Found, deleting ${CurrentFolder}."
		rm -rf $CurrentFolder
	fi
done
