#!/bin/sh

echo -ne "\n******* imageset-mirror.sh ********\n"

_D1=$1
_DP_SOURCE_IS_MANIFESTS=$2
_DP_METADATA=oc-mirror-metadata

_J0=

[[ -d $_DP_METADATA ]] && rm -rf $_DP_METADATA
mkdir $_DP_METADATA

_DP_OC_MIRROR=/tmp/oc-mirror/$_D1
[[ -d $_DP_OC_MIRROR ]] && rm -rf $_DP_OC_MIRROR
mkdir -p $_DP_OC_MIRROR

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

jq ".mirror.operators += ${_J0b}" <<<$_J_IS  > $_DP_OC_MIRROR/imagesetconfiguration.yaml

_FP_IS=$_DP_OC_MIRROR/imagesetconfiguration.yaml

_DP_STORAGE=${DP_STORAGE:-dp_storage}

[[ -d $_DP_STORAGE ]] && rm -rf $_DP_STORAGE
mkdir -p $_DP_STORAGE

echo "ImageSetConfiguration:"

jq . $_FP_IS
read -t 4 -p ..

echo "oc-mirror -c ${_FP_IS} file://${_DP_STORAGE}"
[[ ! $DRYRUN ]] &&
time oc-mirror -c ${_FP_IS} file://${_DP_STORAGE} 

if [[ $? -eq 0 ]]; then
  exit 0
else
  echo "FYI, the following mirroring files (registry upload .tar) have been found:"
  find $_DP_STORAGE -name "*.tar"
fi
  




