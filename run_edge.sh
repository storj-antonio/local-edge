#/bin/bash
set -ue
set -o pipefail
set -o errtrace

traperr() {
	echo "ERROR: ${BASH_SOURCE[1]} near line ${BASH_LINENO[0]} while working with ${CurrentFolder}."
}
trap traperr err

export PATH=$PATH:$HOME/go/bin

if which cockroach >/dev/null; then
	echo "starting cockroach"
	cockroach start-single-node --insecure --listen-addr=localhost
else
    echo "cockroach not installed or isn't in path. Attempting scripted install, this could fail especially if"
	echo "your user isn't in the sudoers file."
	curl https://binaries.cockroachdb.com/cockroach-v21.1.7.linux-amd64.tgz | tar -xz && sudo cp -i cockroach-v21.1.7.linux-amd64/cockroach /usr/local/bin/
	echo "-----------------------------------------------------------------------------"
	rm -rf "cockroach-v21.1.7.linux-amd64/cockroach/"

	if which cockroach >/dev/null; then
		echo "Cockroach installed successfully, starting single-node instance"
		cockroach start-single-node --insecure --listen-addr=localhost
	fi
fi

if which storj-sim >/dev/null; then
	echo "starting storj-sim"
	storj-sim network destroy
	storj-sim network setup --postgres=cockroach://root@localhost:26257?sslmode=disable
	storj-sim network run --no-gateways
else
    echo "storj-sim not installed or isn't in path. Try running clone-repos.sh."
fi
