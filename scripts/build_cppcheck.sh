#!/bin/bash
#
# Copyright 2016 by Bill Torpey. All Rights Reserved.
# This work is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 United States License.
# http://creativecommons.org/licenses/by-nc-nd/3.0/us/deed.en
#
set -exv

PACKAGE=cppcheck
VERSION=1.73

#
# NOTE: cppcheck requires pcre-devel package (yum install pcre-devel)
#

# location where package should be installed
INSTALL_PREFIX=/build/share/${PACKAGE}/${VERSION}
# uncomment following to get verbose output from make
#VERBOSE=VERBOSE=1

# find compiler libraries to use in RPATH setting
COMPILER=${CXX}
[[ -z ${COMPILER} ]] && COMPILER=g++
RPATH=$(dirname $(dirname $(which ${COMPILER})))/lib64

[[ -e ${PACKAGE}-${VERSION}.tar.gz ]] || wget --no-check-certificate -nv https://sourceforge.net/projects/${PACKAGE}/files/${PACKAGE}/${VERSION}/${PACKAGE}-${VERSION}.tar.gz

rm -rf ${PACKAGE}-${VERSION}
tar xvfz ${PACKAGE}-${VERSION}.tar.gz

# delete old
rm -rf ${INSTALL_PREFIX}

cd ${PACKAGE}-${VERSION}
make clean
make ${VERBOSE} PREFIX=${INSTALL_PREFIX} CFGDIR=${INSTALL_PREFIX}/cfg HAVE_RULES=yes LDFLAGS="-Wl,--rpath=${RPATH}" install
