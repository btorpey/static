# cc_pvs.sh

This script is a wrapper for PVS_Studio (<https://www.viva64.com/en/pvs-studio/>) static analyzer. It simplifies running PVS on a tree of source files using a compilation database (`compile_commands.json`).

## Usage
cc_pvs.sh [-d] [-p build\_path]
[-i include\_pattern] [-x exclude\_pattern] [-c] [-g config\_file]

## Parameters

Parameter | Description
--- | ---
-d  |   Debug -- print generated command to stdout, but don't execute it.  
-i include_pattern | File paths matching include_pattern are included in generated commands.  May be specified multiple times.  If omitted, all files in the compilation database are included.  Note that the pattern is *NOT* a file-globbing pattern, but simply a regex evaluated using Perl.
-x exclude_pattern | File paths matching exclude_pattern are not included in generated commands.  May be specified multiple times.  All exclude_patterns are matched after any include patterns, so exclude patterns effectively override include patterns.
-p build\_path  |   Specifies the path to a compilation database in JSON format.  It can be either an absolute path to a compilation database, or a directory (which will be searched for a compile\_commands.json file).  If omitted, the current directory is used.
-c  | Create output in csv format, using the .csv file extension.  
-g config  |   Specifies the path to a PVS-Studio configiuration file.If omitted, it defaults to `$HOME/.config/PVS-Studio/PVS-Studio.cfg`.

## Configuration
The script looks for the file `.pvsconfig` in the root of the source tree -- if found, it passes the file's full path to PVS with the `--rules-config` flag.

## Notes

The format of PVS-Studio output has changed previously -- this version of the utility is compatible with version 7.12.  With this version, the `pvs-studio` standalone program has been deprecated -- this script now uses `pvs-studio-analyzer`.

See [this series of posts](http://btorpey.github.io/blog/categories/static-analysis/) for more information.
