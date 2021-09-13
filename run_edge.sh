#!/bin/bash
set -ue
set -o pipefail
set -o errtrace

traperr() {
	echo "ERROR: ${BASH_SOURCE[1]} near line ${BASH_LINENO[0]} while working with ${CurrentFolder}."
}
trap traperr ERR
