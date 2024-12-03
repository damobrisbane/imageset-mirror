#!/bin/bash

function sorted0() {
  local -n _l2=$1

  oIFS=$IFS IFS=$' \r\n'
  local sorted_list=($(echo "${_l2[@]}" | tr " " "\n" | sort -nu))

  echo ${sorted_list[0]}
  IFS=$oIFS

}

p_svr() {

  # p_svr $_DP_TMP  $_LOGIN_URL $_OCP_USER $_PASS
  # p_svr /tmp/tmp.FQxAt2aiRZ  https://api.xxx.lan:6443 <user> <password>

  local -n _SUB_CH_LOCAL=$1
  local _DP_TMP=$2
  local _LOGIN_URL=$3
  local _OCP_USER=$4
  local _PASS=$5

  if [[ $_PASS ]]; then
   oc login --server=${_LOGIN_URL} -u ${_OCP_USER} -p ${_PASS}
  else
   oc login --server=${_LOGIN_URL} -u ${_OCP_USER} 
  fi

  if [[ $? -ne 0 ]]; then
    echo "Unable to login as \"${_OCP_USER}\", exiting.."
    exit
  else
    export _TOKEN=$(oc whoami -t)
  fi
  IFS=$'\n'
  L1=($(oc get subs -A -o go-template='{{range .items}}{{.metadata.namespace}} {{.metadata.name}} {{.spec.name}}{{"\n"}}{{end}}'))

  for l in ${L1[@]}; do

    IFS=$' \r\n'
    read _NS _SUBS_NAME _PKG_NAME <<<${l[@]}

    #echo "processing $_NS $_SUBS_NAME $_PKG_NAME" 1>&2

    _J1=$(oc get subs $_SUBS_NAME -n $_NS -o json)

    _CHANNEL=$(jq -r .spec.channel <<<$_J1)
    _INSTALLED_CSV=$(jq -r .status.installedCSV <<<$_J1)

    _J2=$(oc get packagemanifest $_PKG_NAME -n openshift-marketplace -o json)

    _VERSION=$(jq -r ".status.channels[]|select((.name==\"$_CHANNEL\") and (.currentCSV==\"$_INSTALLED_CSV\"))|.currentCSVDesc.version" <<<$_J2)

    _SUB_CH_LOCAL[$_PKG_NAME@$_CHANNEL]+="$_VERSION "

  done

}


_OCP_USER=$OCP_USER
_SVRS=$SVRS
_PASS=$PASS
_NO_LOGOUT=

while getopts "hnu:s:v:" o; do
  case "$o" in
    h) echo -ne "\n[PASS=xxxx] subs_csv.sh -s <ocp_n1.int.lan,ocp_n2.int.lan,..> -u <OCP_USER> [-n (no logout)]\n\n" && exit ;;
    n) _NO_LOGOUT=1 ;;
    u) _OCP_USER=$OPTARG ;;
    s) _SVRS=$OPTARG ;;
  esac 
done


if [[ -z $_OCP_USER || -z $_SVRS ]]; then
  echo "missing params, exiting.." && exit
fi

_L_SVRS=($(tr , ' ' <<<${_SVRS}))
  
_DP_TMP=$(mktemp -d)

declare -A _SUB_CH

for svr in ${_L_SVRS[@]}; do

  #echo "Processing $svr"
  _LOGIN_URL="https://api.${svr}:6443"
  echo "p_svr $_DP_TMP  $_LOGIN_URL $_OCP_USER xxxxx"
  p_svr _SUB_CH $_DP_TMP  $_LOGIN_URL $_OCP_USER $_PASS

  for i in ${!_SUB_CH[@]}; do
    echo "$i: ${_SUB_CH[$i]}"
  done

  [[ ! $_NO_LOGOUT ]] && oc logout

  #python ./subs_csv.py ${_DP_TMP}

done

