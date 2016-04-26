# build_cppcheck.sh

This script builds cppcheck for installation in a non-standard location (i.e., not /usr or /usr/local).

## Usage
build_cppcheck.sh

## Notes
The script downloads cppcheck, unpacks the compressed tarball, and invokes make on the source directory.

The PACKAGE, VERSION and INSTALL_PREFIX variables can be modified if needed.

