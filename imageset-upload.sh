#!/bin/sh

_D1=$1
_REPO_URL=$2
_DP_STORAGE=${DP_STORAGE:-dp_storage}

[[ ! $DRYRUN ]] &&
[[ -d oc-mirror-workspace ]] && rm -rf oc-mirror-workspace

echo "oc-mirror --from ${_DP_STORAGE} --skip-metadata-check --skip-pruning docker://$_REPO_URL"

[[ ! $DRYRUN ]] &&
#time oc-mirror --from ${_DP_STORAGE} --skip-cleanup --skip-metadata-check --skip-pruning docker://$_REPO_URL
time oc-mirror --from ${_DP_STORAGE} --skip-metadata-check --skip-pruning docker://$_REPO_URL

[[ ! $DRYRUN ]] &&
[[ -d /tmp/oc-mirror/${_D1}/results ]] && rm -rf /tmp/oc-mirror/${_D1}/results
mkdir -p /tmp/oc-mirror/${_D1}/results

_DP_RESULT1=$(find oc-mirror-workspace -type d -name "results-*" 2>/dev/null)

if [[ ! $DRYRUN ]]; then
  if [[ -d $_DP_RESULT1 ]]; then
    echo "cp -dpR $_DP_RESULT1/* /tmp/oc-mirror/${_D1}/results"
    cp -dpR $_DP_RESULT1/* /tmp/oc-mirror/${_D1}/results
    find /tmp/oc-mirror/${_D1}
  else
    echo "no $_DP_RESULT1 directory found, no results posted for content source uploads"
  fi
fi




