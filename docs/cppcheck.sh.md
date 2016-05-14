# cppcheck.sh
{:.no_toc}

This script wraps cppcheck and supplies common parameters, as well as pre-defined compiler definitions.

## Usage
cppcheck.sh [parameters] [file]

## Notes
This script is normally invoked through the cc_driver.pl script, which supplies definitions from the file's entry in the compilation database (`-I` and `-D` parameters).

The script generates a file containing the compiler's pre-defined macro definitions, which is input to cppcheck using cppcheck's `--include=` flag.

See [this post](/blog/2016/04/07/mo-static) for more information.
