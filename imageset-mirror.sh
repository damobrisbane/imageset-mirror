#!/bin/sh

_D1=${DATE:-$(date +%Y%m%d)}

_DP_SOURCE_IS_MANIFESTS=$1
_REPO_URL=$2

_J0=

for _j in $(find $_DP_SOURCE_IS_MANIFESTS -type f); do

  _J1=$(jq -c ". += {\"targetTag\":\"$_D1\"}" $_j)
  _J0+=$_J1

done

_J0b=$(jq -s . <<<$_J0)

read -d '' -r _J_IS <<EOF
  {
    "kind": "ImageSetConfiguration",
    "apiVersion": "mirror.openshift.io/v1alpha2",
    "storageConfig": {
      "local": {
        "path": "/tmp/oc-mirror-metadata"
      }
    },
    "archiveSize": 4,
    "mirror": {
      "operators": []
    }
  }
EOF

_DP_TMP=$(mktemp -d)

jq ".mirror.operators += ${_J0b}" <<<$_J_IS  > $_DP_TMP/imagesetconfiguration.yaml

_FP_IS=$_DP_TMP/imagesetconfiguration.yaml

_DP_STORAGE=${DP_STORAGE:-/tmp/dp_storage}

[[ ! -d $_DP_STORAGE ]] && mkdir -p $_DP_STORAGE

echo "ImageSetConfiguration:"

cat $_FP_IS

echo "oc-mirror -c ${_FP_IS}  file://${_DP_STORAGE}"
read -p ..
oc-mirror -c ${_FP_IS}  file://${_DP_STORAGE} 

echo "oc-mirror --from ./${_DP_STORAGE} --skip-image-pin --skip-cleanup --skip-metadata-check --skip-missing --skip-pruning docker://$_REPO_URL/$_D1"

oc-mirror --from ./${_DP_STORAGE} --skip-image-pin --skip-cleanup --skip-metadata-check --skip-missing --skip-pruning docker://$_REPO_URL/$_D1
