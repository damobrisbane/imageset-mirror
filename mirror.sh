#!/bin/sh

echo -ne "******* mirror.sh ********\n"

_DP_MANIFESTS=${DP_MANIFESTS:-manifests}

_REPO_URL=$1
_D1=${D1:-$(date +%Y%m%d-%H%M)}

_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "$_SCRIPT_DIR/imageset-mirror.sh $_D1 $_DP_MANIFESTS"
read -t 4 -p ..
$_SCRIPT_DIR/imageset-mirror.sh $_D1 $_DP_MANIFESTS

echo "$_SCRIPT_DIR/imageset-upload.sh $_D1 $_REPO_URL"
read -t 4 -p ..
$_SCRIPT_DIR/imageset-upload.sh $_D1 $_REPO_URL
