#!/bin/bash
set -ue
set -o pipefail
set -o errtrace

CurrentFolder="notset"
Location="$( cd "$( dirname "${BASH_SOURCE[0]}"   )" >/dev/null 2>&1 && pwd   )"

traperr() {
	echo "ERROR: ${BASH_SOURCE[1]} near line ${BASH_LINENO[0]} while working with ${CurrentFolder}."
}
trap traperr ERR

echo "Building satellite web ui"
cd "${Location}/storj/web/satellite/"
npm install
npm run build

echo "Building storagenode web ui"
cd "${location}/storj/web/storagenode/"
npm install
npm run build

echo "Building WASM"
# Generate WASM
cd "${Location}/storj/"
make satellite-wasm
mv release/*/wasm/* web/satellite/static/wasm/
