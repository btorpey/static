# Static Analysis Helper Scripts
A few scripts that can be helpful in the use and evaluation of C++ static analysis tools.

A blog post describing the use of these scripts with cppcheck and clang can be found at [](http://btorpey.github.io/blog/2015/10/13/remote-scripting-with-bash-and-ssh/).

Script  | Description
------------- | -------------
build_cppcheck.sh | Script to build cppcheck for installation in a non-standard location (i.e., not /usr, /usr/local).
cc_driver.pl  | Iterates over a compilation database (compile_commands.json) file, and executes a specified command for each build target, passing the compiler flags from the normal build.
cppcheck.sh | Invokes cppcheck defining a number of common parameters, also generates and includes compiler pre-defined macros.
cppcheck2csv.pl  | Takes (filtered or un-filtered) output from cppcheck, and formats it in csv format.
clang2csv.pl  | Takes (filtered or un-filtered) output from clang tools (clang-check and clang-tidy), and formats it in csv format.
itc2csv.pl  | Takes a list of error annotations from ITC benchmark suite, and formats it in csv format.

Most of the scripts are written in Perl, simply because that was easiest (especially given the excellent debugging support available under [Eclipse](https://eclipse.org/) with [EPIC](http://www.epic-ide.org/)).

The scripts have been tested on CentOS 6.

Copyright 2016 by Bill Torpey. All Rights Reserved.
This work is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 United States License. <http://creativecommons.org/licenses/by-nc-nd/3.0/us/deed.en>



