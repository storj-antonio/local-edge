#!/usr/bin/env bash

set -euo pipefail

FAIL=0

go install -race -v storj.io/storj/cmd/satellite@latest &
go install -race -v storj.io/storj/cmd/storagenode@latest &
go install -race -v storj.io/storj/cmd/storj-sim@latest &
go install -race -v storj.io/storj/cmd/versioncontrol@latest &
go install -race -v storj.io/storj/cmd/uplink@latest &
go install -race -v storj.io/storj/cmd/identity@latest &
go install -race -v storj.io/storj/cmd/certificates@latest &
go install -race -v storj.io/storj/cmd/multinode@latest &
go install -race -v storj.io/gateway@latest &



for job in `jobs -p`
do
echo $job
    wait $job || let "FAIL+=1"
done

echo $FAIL

if [ "$FAIL" == "0"  ]; then
    git clone git@github.com:storj/storj.git #grabbing the repo so that we can build the web ui
    ./start-services.sh
fi
