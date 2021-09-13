#!/bin/bash
set -ue
set -o pipefail
set -o errtrace

traperr() {
	echo "ERROR: ${BASH_SOURCE[1]} near line ${BASH_LINENO[0]} while working with ${CurrentFolder}."
}
trap traperr ERR

export PATH=$PATH:$HOME/go/bin

if which cockroach >/dev/null; then
	echo "starting cockroach"
	cockroach start-single-node --insecure --listen-addr=localhost
else
    echo "cockroach not installed or isn't in path."
fi

if which storj-sim >/dev/null; then
	echo "starting storj-sim"
	storj-sim network destroy
	storj-sim network setup --postgres=cockroach://root@localhost:26257?sslmode=disable
	storj-sim network run --no-gateways
else
    echo "storj-sim not installed or isn't in path."
fi
