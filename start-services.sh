#!/bin/bash
set -ue
set -o pipefail

export PATH=$PATH:$HOME/go/bin

traperr() {
	echo "ERROR: ${BASH_SOURCE[1]} near line ${BASH_LINENO[0]} while working with ${CurrentFolder}."
	echo "Kill Services..."
	# trap 'pkill -P $$' SIGINT SIGTERM EXIT <---- Try this one at a later time. This guy kills all subprocesses.
	for value in "${serv_pid[@]}"; do
		kill value
	done
}
trap traperr SIGINT SIGTERM EXIT

declare -A serv_pid

if which cockroach >/dev/null; then
	echo "starting cockroach..."
	cockroach start-single-node --insecure --listen-addr=localhost&
	serv_pid[cockroach]="${!}"
else
    echo "cockroach not installed or isn't in path. Attempting scripted install."
	curl https://binaries.cockroachdb.com/cockroach-v21.1.7.linux-amd64.tgz | tar -xz && sudo cp -i cockroach-v21.1.7.linux-amd64/cockroach /usr/local/bin/
	echo "-----------------------------------------------------------------------------"
	rm -rf "cockroach-v21.1.7.linux-amd64/cockroach/"

	if which cockroach >/dev/null; then
		echo "Cockroach installed successfully, starting single-node instance"
		cockroach start-single-node --insecure --listen-addr=localhost&
		serv_pid[cockroach]="${!}"
	fi
fi

if which storj-sim >/dev/null; then
	echo "starting storj-sim"
	storj-sim network destroy
	storj-sim network setup --postgres=cockroach://root@localhost:26257?sslmode=disable
	storj-sim network run --no-gateways&
	serv_pid[storj-sim]="${!}"
else
    echo "storj-sim not installed or isn't in path. Try running clone-repos.sh."
fi

if which authservice >/dev/null; then
	echo "starting authservice"
	authservice run --allowed-satellites $(storj-sim network env SATELLITE_0_ID)@$(storj-sim network env SATELLITE_0_ADDR) --auth-token my-test-auth-token --endpoint http://localhost:8002 --kv-backend memory://&
	serv_pid[authservice]="${!}"
else
	echo "authservice not installed or isn't in path. Try running clone-repo.sh."
fi

if which gateway-mt >/dev/null; then
	echo "starting gateway-mt"
	gateway-mt run $(storj-sim network env SATELLITE_0_ID)@$(storj-sim network env SATELLITE_0_ADDR) --auth-token my-test-auth-token --auth-url http://localhost:8000 --domain-name localhost --server.address localhost:8002 --insecure-disable-tls&
	serv_pid['gateway-mt']="${!}"
else
	echo "gateway-mt not installed or isn't in path. Try running clone-repo.sh."
fi

if which linksharing >/dev/null; then
	echo "starting linksharing"
	linksharing run --auth-service.base-url=http://localhost:8000 --auth-service.token=my-test-auth-token --address=localhost:8001 --public-url=http://localhost:8001 --log.level=debug --geo-location-db=./GeoLite2-City.mmdb
	serv_pid['linksharing']="${!}"
else
	echo "linksharing not installed or isn't in path. Try running clone-repo.sh."
fi
