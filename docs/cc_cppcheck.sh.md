# cc_cppcheck.sh

This script is a wrapper for a couple of helper scripts: cc_driver.pl and cppcheck.sh.  It simplifies running cppcheck on a tree of source files using a compilation database (`compile_commands.json`).

## Usage
cc_cppcheck.sh [-d] [-v] [-p build\_path]
[-i include\_pattern] [parameters]

## Parameters

Parameter | Description
--- | ---
-d  |   Debug -- print generated command to stdout, but don't execute it.  
-i include_pattern | File paths matching include_pattern are included in generated commands.  May be specified multiple times.  If omitted, all files in the compilation database are included.  Note that the pattern is *NOT* a file-globbing pattern, but simply a regex evaluated using Perl.
-x exclude_pattern | File paths matching exclude_pattern are not included in generated commands.  May be specified multiple times.  All exclude_patterns are matched after any include patterns, so exclude patterns effectively override include patterns.
-p build\_path  |   Specifies the path to a compilation database in JSON format.  It can be either an absolute path to a compilation database, or a directory (which will be searched for a compile\_commands.json file).  If omitted, the current directory is used.
-c  | Create output in csv format, using the .csv file extension.  

## Configuration
The script looks for the file `.cppcheckrc` in the source files's directory and its parents.  If found, the contents of that file are passed to `cppcheck` as command line parameters.  Blank lines and comment lines (lines beginning with `#`) are ignored.

A typical `.cppcheckrc` file might look something like this:

    # this is a comment
    --enable=all --inconclusive
    --error-exitcode=19
    --std=posix --std=c++03
    --platform=unix64
    
    --suppress=unusedFunction
    --suppress=unmatchedSuppression


## Notes

See [this series of posts](/blog/categories/static-analysis/) for more information.
