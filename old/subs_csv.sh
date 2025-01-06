#!/bin/bash

_log_stderr() {
  printf '%s\n' "$@" 1>&2
}

_log() {
  printf '%s\n' "$@"
}


function sorted0() {
  local -n _l2=$1

  oIFS=$IFS IFS=$' \r\n'
  local sorted_list=($(_log_stderr "${_l2[@]}" | tr " " "\n" | sort -nu))

  _log_stderr ${sorted_list[0]}
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
   oc login --server=${_LOGIN_URL} -u ${_OCP_USER} -p ${_PASS} >/dev/null 2>&1
  else
   oc login --server=${_LOGIN_URL} -u ${_OCP_USER} >/dev/null 2>&1
  fi

  if [[ $? -ne 0 ]]; then
    _log_stderr "Unable to login as \"${_OCP_USER}\", exiting.."
    exit
  else
    export _TOKEN=$(oc whoami -t)
  fi
  IFS=$'\n'
  L1=($(oc get subs -A -o go-template='{{range .items}}{{.metadata.namespace}} {{.metadata.name}} {{.spec.name}}{{"\n"}}{{end}}'))


  for l in ${L1[@]}; do

    IFS=$' \r\n'
    read _NS _SUBS_NAME _PKG_NAME <<<${l[@]}

    #_log_stderr "processing $_NS $_SUBS_NAME $_PKG_NAME" 1>&2

    _J1=$(oc get subs $_SUBS_NAME -n $_NS -o json)

    _CHANNEL=$(jq -r .spec.channel <<<$_J1)
    _INSTALLED_CSV=$(jq -r .status.installedCSV <<<$_J1)

    _J2=$(oc get packagemanifest $_PKG_NAME -n openshift-marketplace -o json)

    _VERSION=$(jq -r ".status.channels[]|select((.name==\"$_CHANNEL\") and (.currentCSV==\"$_INSTALLED_CSV\"))|.currentCSVDesc.version" <<<$_J2)

    _SUB_CH_LOCAL[$_PKG_NAME@$_CHANNEL]+="$_VERSION"

  done

}

f_aggregate_subs() {

  local -n _J_F1=$1

  local -A _SUB_CH

  _log_stderr "Processing $svr"
  _LOGIN_URL="https://api.${svr}:6443"

  p_svr _SUB_CH $_DP_TMP  $_LOGIN_URL $_OCP_USER $_PASS

  _J1="{\"$svr\":{}}"

  for i in ${!_SUB_CH[@]}; do

    _log_stderr "$i: ${_SUB_CH[$i]}"

    #_J1=$(jq -c ".\"$svr\" += [{\"${_operator}\":{\"ch\":\"$_ch\",\"ver\":\"${_SUB_CH[$i]}\"}}]" <<<$_J1)
    _J1=$(jq -c ".\"$svr\" += {\"${i}\":\"${_SUB_CH[$i]}\"}" <<<$_J1)

  done

  _J_F1=$(jq -c ".subs_csv += [${_J1}]" <<<$_J_F1)

}


_OCP_USER=$OCP_USER
_SVRS=$SVRS
_PASS=$PASS
_NO_LOGOUT=

while getopts "hnu:s:v:" o; do
  case "$o" in
    h) _log_stderr "\n[PASS=xxxx] subs_csv.sh -s <ocp_n1.int.lan,ocp_n2.int.lan,..> -u <OCP_USER> [-n (no logout)]\n\n" && exit ;;
    n) _NO_LOGOUT=1 ;;
    u) _OCP_USER=$OPTARG ;;
    s) _SVRS=$OPTARG ;;
  esac 
done

_DP_SUBS_CSV=/tmp/oc-mirror/subs_csv
[[ -d $_DP_SUBS_CSV ]] && rm -rf $_DP_SUBS_CSV
mkdir -p $_DP_SUBS_CSV

if [[ -z $_OCP_USER || -z $_SVRS ]]; then
  _log_stderr "missing params, exiting.." && exit
fi

_L_SVRS=($(tr , ' ' <<<${_SVRS}))
  
_DP_TMP=$(mktemp -d)


read -d '' -r _J_SUBS_CSV <<EOF
  {
    "subs_csv": []
  }
EOF

for svr in ${_L_SVRS[@]}; do
  f_aggregate_subs _J_SUBS_CSV
done

[[ ! $_NO_LOGOUT ]] && oc logout

_RC=1
jq . <<<$_J_SUBS_CSV >/dev/null 2>&1
if [[ $? -eq 0 ]]; then 
  _RC=0
  jq . <<<$_J_SUBS_CSV > ${_DP_SUBS_CSV}/aggregated_subs.json
  _log ${_DP_SUBS_CSV}/aggregated_subs.json
fi  

exit $_RC

#python ./subs_csv.py ${_DP_TMP}

