#!/bin/bash -xv

# ensure helper scripts are available
SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE}) && /bin/pwd)
export PATH=${SCRIPT_DIR}:$PATH

# assume source is in current dir
export SRC_ROOT=$(pwd)

# check to make sure we have what we need
which pvs-studio-analyzer 2>&1 >/dev/null
if [[ $? -ne 0 ]]; then
   >&2 echo "pvs-studio-analyzer not found!"
   exit 1
fi
which plog-converter 2>&1 >/dev/null
if [[ $? -ne 0 ]]; then
   >&2 echo "plog-converter not found!"
   exit 1
fi

TYPE=errorfile
DEBUG=0
CSV=0
CCFILE=""
export INCLUDE=""
export EXCLUDE=""
while getopts ':cdp:i:x:' flag; do
  case "${flag}" in
    c) CSV=1 ; TYPE=csv ;;
    d) DEBUG=1 ;;
    p) export CCFILE="-f ${OPTARG}" ;;
    i) export INCLUDE="${INCLUDE} -i ${OPTARG}" ;;
    x) export EXCLUDE="${EXCLUDE} -e ${OPTARG}" ;;
  esac
done
shift $(($OPTIND - 1))

TEMPFILE=$(mktemp /tmp/pvstemp.XXXXXX)
TEMPFILE2=$(mktemp /tmp/pvstemp.XXXXXX)

pvs-studio-analyzer analyze ${CCFILE} -q --platform linux64 -o ${TEMPFILE} -r ${SRC_ROOT} 2>/dev/null >/dev/null
plog-converter -t ${TYPE} -r ${SRC_ROOT} ${TEMPFILE} -o ${TEMPFILE2} 2>/dev/null >/dev/null
if [[ ${CSV} == 1 ]] ; then
   cat ${TEMPFILE2} | sed "s:${SRC_ROOT}\/::g" | pvs2csv.pl | sort -u
else
   cat ${TEMPFILE2} | sed "s:${SRC_ROOT}\/::g" | sort -u
fi
