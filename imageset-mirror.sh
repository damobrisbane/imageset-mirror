#!/bin/sh

_D1=${DATE:-$(date +%Y%m%d)}

_DP_SOURCE_IS_MANIFESTS=$1
_REPO_URL=$2
_DP_METADATA=/data2/oc-mirror/oc-mirror-metadata
_DP_OC_MIRROR_WORKSPACE=oc-mirror-workspace

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
        "path": "${_DP_METADATA}"
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

_DP_STORAGE=${DP_STORAGE:-/data2/oc-mirror/dp_storage}

#for i in $_DP_METADATA $_DP_STORAGE $_DP_OC_MIRROR_WORKSPACE; do
#  if [[ ! $DRYRUN ]]; then
#    [[ -d $i ]] && rm -rf $i
#    mkdir -p $i
#  fi
#done

echo "ImageSetConfiguration:"

jq . $_FP_IS
read -t 4 -p ..

#echo "oc-mirror -c ${_FP_IS} --skip-image-pin  file://${_DP_STORAGE}"
#[[ ! $DRYRUN ]] &&
#oc-mirror -c ${_FP_IS} --skip-image-pin file://${_DP_STORAGE} 
echo "oc-mirror -c ${_FP_IS} file://${_DP_STORAGE}"
[[ ! $DRYRUN ]] &&
time oc-mirror -c ${_FP_IS} file://${_DP_STORAGE} 

if [[ $? -eq 0 ]]; then
  echo "return: 0"
else
  echo "return: 1"
fi

read -t 4 -p ..
echo "oc-mirror --from ${_DP_STORAGE} --skip-cleanup --skip-metadata-check --skip-pruning docker://$_REPO_URL"
[[ ! $DRYRUN ]] &&
time oc-mirror --from ${_DP_STORAGE} --skip-cleanup --skip-metadata-check --skip-pruning docker://$_REPO_URL
