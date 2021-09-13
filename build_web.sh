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

cd "${Location}/storj/web/satellite/"
npm install
npm run build

cd "${location}/storj/web/storagenode/"
npm install
npm run build

# Generate WASM
cd "${Location}/storj/"
make satellite-wasm
mv release/*/wasm/* web/satellite/static/wasm/
