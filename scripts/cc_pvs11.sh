#!/bin/bash -xv

# ensure helper scripts are available
SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE}) && /bin/pwd)
export PATH=${SCRIPT_DIR}:$PATH

# assume source is in current dir
export SRC_ROOT=$(pwd)
# in case SRC_ROOT is actually a symlink
export SRC_ROOT2=$(/bin/pwd)

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

if [[ -e ${SRC_ROOT}/.pvsconfig ]]; then
   PVSCONFIG="--rules-config ${SRC_ROOT}/.pvsconfig"
fi

SKIP=9
TYPE=errorfile
CSV=cat
CONFIG="--cfg $HOME/.config/PVS-Studio/PVS-Studio.cfg"
# get params, pass through anything we don't use
# see https://stackoverflow.com/a/40089073/3394490
CSV=cat
passThru=() # init. pass-through array
while getopts ':cg:' opt; do # look only for *own* options
  case "$opt" in
    c) CSV=pvs2csv.pl ; TYPE=csv; SKIP=10 ;;
    g) export CONFIG="--cfg ${OPTARG}" ;;
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


TEMPFILE=$(mktemp /tmp/pvsstudio-XXXX)
rm -f ${TEMPFILE} 2>&1 >/dev/null

# iterate over compilation db and generate results
cc_driver.pl "${passThru[@]}" pvs-studio-analyzer analyze ${CONFIG} --output-file ${TEMPFILE} >/dev/null
if [[ $? != 0 ]]; then
   echo "..."
   tail ${TEMPFILE}
   echo -e "\n\n*** Analysis failed -- see ${TEMPFILE}"
   exit 1
fi

# filter etc.
plog-converter -t ${TYPE} ${TEMPFILE} |
tail -n +${SKIP} |                                 # skip plog-converter banner
egrep -v 'Filtered messages|Total messages' |      # filter superfluous messages
sed -r "s:${SRC_ROOT}\/|${SRC_ROOT2}\/::g" |       # make all paths under SRC_ROOT relative
sed 's:^\.\./::' |                                 # filter out leading "../" in paths (reduce duplicate reports)
${CSV} | sort -u

#rm -f ${TEMPFILE} >/dev/null 2>&1
