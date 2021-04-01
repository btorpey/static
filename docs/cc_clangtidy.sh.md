# cc_clangtidy.sh

This script is a wrapper for the [clang-tidy](https://clang.llvm.org/extra/clang-tidy/) static analyzer. It simplifies running clang-tidy on a tree of source files using a compilation database (`compile_commands.json`).

## Usage
cc_clangtidy.sh [-d] [-p build\_path]
[-i include\_pattern] [-x exclude\_pattern] [-c] [-g config\_file]

## Parameters

Parameter | Description
--- | ---
-d  |   Debug -- print generated command to stdout, but don't execute it.  
-i include_pattern | File paths matching include_pattern are included in generated commands.  May be specified multiple times.  If omitted, all files in the compilation database are included.  Note that the pattern is *NOT* a file-globbing pattern, but simply a regex evaluated using Perl.
-x exclude_pattern | File paths matching exclude_pattern are not included in generated commands.  May be specified multiple times.  All exclude_patterns are matched after any include patterns, so exclude patterns effectively override include patterns.
-p build\_path  |   Specifies the path to a compilation database in JSON format.  It can be either an absolute path to a compilation database, or a directory (which will be searched for a compile\_commands.json file).  If omitted, the current directory is used.
-c  | Create output in csv format, using the .csv file extension.  

## Configuration
`clang-tidy` looks for a file named `.clang-tidy` in the source files's directory and its parents.  If found, the contents of that file are used to configure checks, etc.  The contents of the file are not particularly well-documented, but some info can be found at [this StackOverflow question](https://stackoverflow.com/questions/53026453/what-values-are-allowed-in-the-clang-tidy-config-file).

## Notes
The `cc_clangcheck.sh` script has been deleted -- `cc_clangtidy.sh` does everything the other script did and more.
