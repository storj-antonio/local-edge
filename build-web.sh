#!/bin/bash
set -ue
set -o pipefail

CurrentFolder="notset"
Location="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd  )"
echo "This script is running from: ${Location}."

traperr() {
	echo "ERROR: ${BASH_SOURCE[1]} near line ${BASH_LINENO[0]}."
}
trap traperr err

echo "Building satellite web ui"
cd "${Location}/storj/web/satellite/"
npm install
npm run build

echo "Building storagenode web ui"
cd "${Location}/storj/web/storagenode/"
npm install
npm run build

echo "Building WASM"
# Generate WASM
cd "${Location}/storj/satellite/console/wasm/"
GOOS=js GOARCH=wasm go build -o access.wasm storj.io/storj/satellite/console/wasm
cp "$(go env GOROOT)/misc/wasm/wasm_exec.js" .
echo "wasm built"
cd "${Location}"

# Enable generate S3 Credentials
echo "Enable generation of S3 Credentials in Satellite UI"
echo "console.gateway-credentials-request-url: "http://127.0.0.1:8000"" >> ~/.local/share/storj/local-network/satellite/0/config.yaml
echo "console.file-browser-flow-disabled: false" >> ~/.local/share/storj/local-network/satellite/0/config.yaml

# Enable Linksharing in Satellite UI 
echo "Enable Linksharing in Satellite UI"
echo "console.linksharing-url: "http://127.0.0.1:8001"" >> ~/.local/share/storj/local-network/satellite/0/config.yaml
