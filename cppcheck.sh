#!/bin/bash
#
# helper script for cppcheck that defines a number of common parameters
# (also generates and includes compiler pre-defined macros)
#
# Copyright 2016 by Bill Torpey. All Rights Reserved.
# This work is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 United States License.
# http://creativecommons.org/licenses/by-nc-nd/3.0/us/deed.en
#

# its a very good idea to include compiler builtin definitions
TEMPFILE=$(mktemp)
cpp -dM </dev/null 2>/dev/null >${TEMPFILE}

# uncomment the following line if you need to override LD_LIBRARY_PATH for cppcheck
# note that you must also supply the required path in place of "<>"
#LD_LIBRARY_PATH=<>:$LD_LIBRARY_PATH \
cppcheck --enable=all --inconclusive \
--std=posix --std=c++03 --std=c++11 \
--include=${TEMPFILE} \
--platform=unix64 \
--suppress=unusedFunction \
--suppress=unmatchedSuppression \
--suppress=missingIncludeSystem \
$*

[[ -f ${TEMPFILE} ]] && rm -f ${TEMPFILE} 2>&1 >/dev/null
