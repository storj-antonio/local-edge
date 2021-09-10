#!/bin/bash
set -ue
set -o traperr
IFS=$' '

CurrentRepo=""
traperr() {
	echo "ERROR: ${BASH_SOURCE[1]} at about ${BASH_LINENO[0]} while working with ${currentRepo}."
}

CloneRepos=("storj" "gateway-mt" "tardigrade-satellite-theme")

for i in ${!CloneRepos[@]};
	$CurrentRepo=$i
do

done
