#!/bin/bash

# ensure helper scripts are available
SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE}) && /bin/pwd)
export PATH=${SCRIPT_DIR}:$PATH

# assume source is in current dir
export SRC_ROOT=$(/bin/pwd)

# check to make sure we have what we need
which cppcheck.sh 2>&1 >/dev/null
if [[ $? -ne 0 ]]; then
   >&2 echo "cppcheck.sh not found!"
   exit 1
fi
which cppcheck 2>&1 >/dev/null
if [[ $? -ne 0 ]]; then
   >&2 echo "cppcheck not found!"
   exit 1
fi

DEBUG=0
CSV=""
CCFILE=""
export INCLUDE=""
export EXCLUDE=""
while getopts ':cdp:i:x:' flag; do
  case "${flag}" in
    c) CSV="| clang2csv.pl" ;;
    d) DEBUG=1 ;;
    p) export CCFILE="-p ${OPTARG}" ;;
    i) export INCLUDE="${INCLUDE} -i ${OPTARG}" ;;
    x) export EXCLUDE="${EXCLUDE} -x ${OPTARG}" ;;
  esac
done
shift $(($OPTIND - 1))

read -r -d '' COMMAND << 'EOF'
# iterate over compilation db, generate and filter results
`which cc_driver.pl` -v ${INCLUDE} ${EXCLUDE} ${CCFILE} `which clang-tidy` 2>&1 |
grep "warning" |                                      # filter out everything but clang diagnostics
sed "s:${SRC_ROOT}\/::g" |                            # make all paths under SRC_ROOT relative
sed 's:^\[\.\./:\[:' |                                # filter out leading "../" in paths (reduce duplicate reports)
sort -u
EOF

if [[ ${DEBUG} -eq 1 ]]; then
   bash -c "echo '${COMMAND} ${SUPPRESS} ${CSV}'"
else
   bash -c "${COMMAND} ${SUPPRESS} ${CSV}"
fi
