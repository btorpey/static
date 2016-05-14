# build_cppcheck.sh
{:.no_toc}

This script builds cppcheck for installation in a non-standard location (i.e., not /usr or /usr/local).

## Usage
build_cppcheck.sh

## Notes
The script downloads cppcheck, unpacks the compressed tarball, and invokes make on the source directory.

The PACKAGE, VERSION and INSTALL_PREFIX variables can be modified if needed.

Since cppcheck requires C++1x support, and since the system compiler on RH6 doesn't support C++1x, we need to build with a different compiler.  Which means that cppcheck needs to be able to find that compiler's libtsdc++ at runtime.  To faciliate that, we set the RPATH of the executable to the library directory of the compiler.  (Note that the approach used assumes we're using gcc).

See [this post](/blog/2016/04/07/mo-static) for more information.

