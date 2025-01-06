#!/bin/sh

_DP_SRC=$1
_DP_PUBLISH=$2


[[ ! -d $_DP_PUBLISH ]] && mkdir -p $_DP_PUBLISH

cp -dpR $_DP_SRC/* $_DP_PUBLISH
