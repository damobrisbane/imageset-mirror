# Automation Friendly ImageSetConfiguration Mirroring

## Mirroring

### Pre-reqs

- shell script
- jq
- docker registry


### Running

./imageset-mirror.sh <DIR_SOURCE_ISC_MANIFESTS> <REPO_URL>

```
# check target state registry


```

```

./mirror1-v1.sh examples/manifests reg.dmz.lan

ImageSetConfiguration:

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
    "operators": [
      {
        "catalog": "registry.redhat.io/redhat/certified-operator-index:v4.14",
        "packages": [
          {
            "name": "gitlab-runner-operator"
          }
        ],
        "targetTag": "20241108"
      },
      {
        "catalog": "registry.redhat.io/redhat/community-operator-index:v4.14",
        "packages": [
          {
            "name": "cert-manager",
            "channels": [
              {
                "name": "stable",
                "minVersion": "1.16.1"
              }
            ]
          }
        ],
        "targetTag": "20241108"
      }
    ]
  }
}
oc-mirror -c /tmp/tmp.tkwqzMVb4H/imagesetconfiguration.yaml  file://.//tmp/dp_storage
..
Found: tmp/dp_storage/oc-mirror-workspace/src/publish
Found: tmp/dp_storage/oc-mirror-workspace/src/v2
Found: tmp/dp_storage/oc-mirror-workspace/src/charts
Found: tmp/dp_storage/oc-mirror-workspace/src/release-signatures
No metadata detected, creating new workspace
wrote mirroring manifests to tmp/dp_storage/oc-mirror-workspace/operators.1731011401/manifests-certified-operator-index

To upload local images to a registry, run:

	oc adm catalog mirror file://redhat/certified-operator-index:v4.14 REGISTRY/REPOSITORY

..
sha256:f292cebd2e819b390c63cd378362b1fa3552e2fc42cacc3ff4bdd6adc54151f9 file://jetstack/cert-manager-webhook
sha256:e8934aababadb81ece148b96b7d893f2e1e47b6eddc5f0e1c073588f36432fca file://jetstack/cert-manager-webhook
sha256:1ee1d5cd6c29c0badd5f73d8b98fcf770a2d47c46ea1761ad83082df7a320280 file://jetstack/cert-manager-webhook
sha256:6edf44244b2a711be737c4ab8e54e68d9112cc4e87da2ef97a7f76b768f4fde7 file://jetstack/cert-manager-webhook:c361d72a
info: Mirroring completed in 1m35.61s (12.76MB/s)
Creating archive /tmp/dp_storage/mirror_seq1_000000.tar
Creating archive /tmp/dp_storage/mirror_seq1_000001.tar

oc-mirror --from ./ --skip-image-pin --skip-cleanup --skip-metadata-check --skip-missing --skip-pruning docker://reg.dmz.lan/20241108
..
Checking push permissions for reg.dmz.lan
using --skip-pruning flag - pruning will be skipped
Publishing image set from archive "./" to registry "reg.dmz.lan"
reg.dmz.lan/
  20241108/gitlab-org/gl-openshift/gitlab-runner-operator/openshift4/ose-kube-rbac-proxy
    blobs:
      file://gitlab-org/gl-openshift/gitlab-runner-operator/openshift4/ose-kube-rbac-proxy sha256:d8190195889efb5333eeec18af9b6c82313edd4db62989bd3a357caca4f13f0e 1.404KiB
sha256:50337e2a6648f985610d6e2ba605bdd38233eb8ea04a5d22118cb29636da730c reg.dmz.lan/20241108/gitlab-org/gl-openshift/gitlab-runner-operator/gitlab-runner-operator:4d9dd392
info: Mirroring completed in 1.07s (70.48MB/s)
skipped pruning
Wrote release signatures to oc-mirror-workspace/results-1731012069
catalogs/registry.redhat.io/redhat/certified-operator-index/20241108/include-config.gob
...
catalogs/registry.redhat.io/redhat/certified-operator-index/20241108/layout/blobs/sha256/6cc631e9ddb4e176949e3c0e8efb24d0fb69cef2a8e8b204418a47a14a22e761
catalogs/registry.redhat.io/redhat/community-operator-index/20241108/layout/blobs/sha256/f80b0f54ea67c69195fa0106732f985973d15ed1de70616067e93996e5d4f107
catalogs/registry.redhat.io/redhat/community-operator-index/20241108/layout/blobs/sha256/fe8b536e4db3fc8af62cf14abb9522a55997c247742b411909457642a3e3a7d5
catalogs/registry.redhat.io/redhat/community-operator-index/20241108/layout/index.json
catalogs/registry.redhat.io/redhat/community-operator-index/20241108/layout/oci-layout
Rendering catalog image "reg.dmz.lan/20241108/redhat/certified-operator-index:20241108" with file-based catalog 
Rendering catalog image "reg.dmz.lan/20241108/redhat/community-operator-index:20241108" with file-based catalog 
Writing image mapping to oc-mirror-workspace/results-1731012069/mapping.txt
Writing CatalogSource manifests to oc-mirror-workspace/results-1731012069
Writing ICSP manifests to oc-mirror-workspace/results-1731012069

```

### Verify Repository

```
curl -s https://reg.dmz.lan/v2/_catalog |jq |grep 2024

    "20241108/community-operator-pipeline-prod/cert-manager",
    "20241108/gitlab/gitlab-runner-operator-bundle",
    "20241108/gitlab-org/ci-cd/gitlab-runner-ubi-images/gitlab-runner-helper-ocp",
    "20241108/gitlab-org/ci-cd/gitlab-runner-ubi-images/gitlab-runner-ocp",
    "20241108/gitlab-org/gl-openshift/gitlab-runner-operator/gitlab-runner-operator",
    "20241108/gitlab-org/gl-openshift/gitlab-runner-operator/openshift4/ose-kube-rbac-proxy",
    "20241108/jetstack/cert-manager-cainjector",
    "20241108/jetstack/cert-manager-controller",
    "20241108/jetstack/cert-manager-webhook",
    "20241108/oc-mirror",
    "20241108/redhat/certified-operator-index",
    "20241108/redhat/community-operator-index",

```

## Pruning

### Pre-reqs

- shell script
- jq
- docker registry path
