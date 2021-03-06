#!/bin/bash
set -u
set -o pipefail

trap traperr err

export GOBIN=~/go/bin
Environment=Test
Clean=False
Source="Github"
CurrentRepo="notset"
ProjectRoot="$( cd "$( dirname "${BASH_SOURCE[0]}"   )" >/dev/null 2>&1 && pwd   )"
CloneRepos=("storj" "gateway-mt" "tardigrade-satellite-theme" "gateway-st")

while getopts "hec" arg; do
	case $arg in
		h)
			Help
			;;
		e)
			Source="gerrit"
			;;
		c)
			Clean="True"
			;;
	esac
done

Help()
{
	Usage
	# echo "Add description of the script functions here."
	echo
	echo "Syntax: ${0} [-e|c|h]"
	echo "options:"
	echo "e		Force environment to dev"
	echo "c     Clean environemnt(delete binaries and remove local dependant packages)."
	echo
}

Usage()
{
	echo "usage: ${0}"
}

traperr() {
	echo "ERROR: ${BASH_SOURCE[1]} near line ${BASH_LINENO[0]} while working with ${CurrentRepo}."
}


##### Begin Script #####
echo "Cloning repos in: ${ProjectRoot}."

for val in "${CloneRepos[@]}"; do
	CurrentRepo=$val

	if [[ -d "${ProjectRoot}/${CurrentRepo}" ]]; then
		echo "${CurrentRepo} folder already exists, skipping checkout."
	else
		if [[ "${Source}" == "Github" ]]; then
			echo "Cloning from github..."
			git clone "git@github.com:storj/${CurrentRepo}.git"
		else
			echo "Cloning ${CurrentRepo} using gerrit support scripts"
			curl -sSL storj.io/clone | sh -s "${CurrentRepo}"
		fi
		# check the Current Repo, if we are cloning gateway-mt then checkout tag1.8.0
		if [[ "${CurrentRepo}" == "gateway-mt" ]]; then
			cd "${CurrentRepo}"
			git checkout tags/v1.8.0
		fi
	fi

	echo "Clean the environment: ${Clean}"
	if [[ $Clean == "True" ]]; then
		cd "${ProjectRoot}/${CurrentRepo}"
		go clean -i all
	fi

	echo "Installing ${CurrentRepo}..."
	if [[ -d "${ProjectRoot}/${CurrentRepo}/cmd/" ]]; then
		echo "${CurrentRepo} has cmd directory"
		cd "${ProjectRoot}/${CurrentRepo}/"
		go install -v ./...
	elif [[ "${CurrentRepo}" == "gateway-st" ]]; then
		cd "${ProjectRoot}/${CurrentRepo}"
		go install -v ./...
	else
		echo "${CurrentRepo} doesn't contain a cmd directory."
		# Tardigrade Branding
		# cp -r "${ProjectRoot}/tardigrade-satellite-theme/europe-west-1/*" "${ProjectRoot}/storj/web/satellite/"
	fi
	cd $ProjectRoot
done
