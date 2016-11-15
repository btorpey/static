#!/bin/bash

SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE}) && /bin/pwd)
# ensure helper scripts are available
export PATH=${SCRIPT_DIR}:$PATH

CSV=""
CCFILE=""
while getopts ':cp:' flag; do
  case "${flag}" in
    c) CSV="| pvs2csv.pl" ;;
    p) export CCFILE="-p ${OPTARG}" ;;
  esac
done
shift $(($OPTIND - 1))

read -r -d '' COMMAND << 'EOF'
pvs-studio-analyzer analyze --cfg ${SCRIPT_DIR}/PVS-Studio.cfg 2>&1     | # run pvs
egrep -v "Renew|Analyzing|Processing|File processed|Analysis finished"  | # discard unwantated output
sed ':a;N;$!ba;s/:\n/: /g'                                              | # combine lines
sed "s:${ITCBENCH_ROOT}\/::g" |                                           # make all paths relative
sort -u
EOF

bash -c "${COMMAND} ${CSV}"
