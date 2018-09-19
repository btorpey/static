#!/bin/bash

# ensure helper scripts are available
SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE}) && /bin/pwd)
export PATH=${SCRIPT_DIR}:$PATH

# assume source is in current dir
export SRC_ROOT=$(pwd)

# check to make sure we have what we need
which pvs-studio 2>&1 >/dev/null
if [[ $? -ne 0 ]]; then
   >&2 echo "pvs-studio not found!"
   exit 1
fi
which plog-converter 2>&1 >/dev/null
if [[ $? -ne 0 ]]; then
   >&2 echo "plog-converter not found!"
   exit 1
fi

TAIL="tail -n +2"
TYPE=errorfile
DEBUG=
CSV=cat
CCFILE=""
INCLUDE=""
EXCLUDE=""
CONFIG=$HOME/.config/PVS-Studio/PVS-Studio.cfg
while getopts ':cdp:i:x:' flag; do
  case "${flag}" in
    c) CSV=pvs2csv.pl ; TYPE=csv; TAIL=cat ;;
    d) DEBUG="-d" ;;
    p) export CCFILE="-p ${OPTARG}" ;;
    i) export INCLUDE="${INCLUDE} -i ${OPTARG}" ;;
    x) export EXCLUDE="${EXCLUDE} -e ${OPTARG}" ;;
    g) export CONFIG="${OPTARG}" ;;
  esac
done
shift $(($OPTIND - 1))


TEMPFILE=$(mktemp /tmp/pvstemp-XXXX)
#echo "TEMPFILE=${TEMPFILE}"
rm -f ${TEMPFILE} 2>&1 >/dev/null

# iterate over compilation db, generate and filter results
cc_driver.pl ${DEBUG} ${INCLUDE} ${EXCLUDE} ${CCFILE} pvs-studio --cfg ${CONFIG} --output-file ${TEMPFILE}
plog-converter -t ${TYPE} ${TEMPFILE} |
${TAIL} |                                             # skip summary message (not for csv format)
egrep -v 'Filtered messages|Total messages' |         # filter superfluous messages
sed "s:${SRC_ROOT}\/::g" |                            # make all paths under SRC_ROOT relative
sed 's:^\.\./::' |                                    # filter out leading "../" in paths (reduce duplicate reports)
${CSV} |                                              # convert to csv format, if necessary
sort -u

rm -f ${TEMPFILE} 2>&1 >/dev/null
