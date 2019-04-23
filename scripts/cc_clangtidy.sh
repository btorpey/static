#!/bin/bash

# ensure helper scripts are available
SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE}) && /bin/pwd)
export PATH=${SCRIPT_DIR}:$PATH

# assume source is in current dir
export SRC_ROOT=$(pwd)
# in case SRC_ROOT is actually a symlink
export SRC_ROOT2=$(/bin/pwd)

# check to make sure we have what we need
which clang-tidy 2>&1 >/dev/null
if [[ $? -ne 0 ]]; then
   >&2 echo "clang-tidy not found!"
   exit 1
fi

# get params, pass through anything we don't use
# see https://stackoverflow.com/a/40089073/3394490
CSV=cat
passThru=() # init. pass-through array
while getopts ':c' opt; do # look only for *own* options
  case "$opt" in
    c) CSV="clang2csv.pl" ;;
    *) passThru+=( "-$OPTARG" )
       if [[ ${@: OPTIND:1} != -* ]]; then
         passThru+=( "${@: OPTIND:1}" )
         (( ++OPTIND ))
       fi
       ;;
  esac
done
shift $((OPTIND - 1))
passThru+=( "$@" )

TEMPFILE=$(mktemp /tmp/clangtidy-XXXX)
rm -f ${TEMPFILE} 2>&1 >/dev/null

# iterate over compilation db and generate results
${SCRIPT_DIR}/cc_driver.pl "${passThru[@]}" `which clang-tidy` >${TEMPFILE}
if [[ $? != 0 ]]; then
   echo "..."
   tail ${TEMPFILE}
   echo -e "\n\n*** Analysis failed -- see ${TEMPFILE}"
   exit 1
fi

# filter etc.
grep "warning:" ${TEMPFILE} |                 # filter out everything but clang diagnostics
sed -r "s:${SRC_ROOT}\/|${SRC_ROOT2}\/::g" |  # make all paths under SRC_ROOT relative
sed 's:^\.\./::' |                            # filter out leading "../" in paths (reduce duplicate reports)
${CSV} | sort -u

rm -f ${TEMPFILE} 2>&1 >/dev/null
