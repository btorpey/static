#!/bin/bash
#
# Copyright 2021 by Bill Torpey. All Rights Reserved.
# This work is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 United States License.
# http://creativecommons.org/licenses/by-nc-nd/3.0/us/deed.en
#
set -exv

## NOTE: cppcheck includes code written in C++11, so needs a C++11-capable compiler

PACKAGE=cppcheck
VERSION=2.3

# location where gcc should be installed
INSTALL_PREFIX=/build/share/${PACKAGE}/${VERSION}
# number of cores
CPUS=1
# uncomment following to get verbose output from make
#VERBOSE=VERBOSE=1

rm -rf ${PACKAGE}-${VERSION}
git clone https://github.com/danmar/cppcheck.git ${PACKAGE}-${VERSION}

# delete old
rm -rf ${INSTALL_PREFIX}

cd ${PACKAGE}-${VERSION}
make clean
make PREFIX=${INSTALL_PREFIX} FILESDIR=${INSTALL_PREFIX} CFGDIR=${INSTALL_PREFIX}/cfg HAVE_RULES=no install
