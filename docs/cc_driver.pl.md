# cc_driver.pl
{:.no_toc}

This script parses a [compilation database](http://clang.llvm.org/docs/JSONCompilationDatabase.html), and executes a specified command for each matching file in the database.  It generates a command that includes the `-I` and `-D` parameters used in the original compilation.

## Usage

cc\_driver.pl [-d] [-v] [-s] [-n] [-p build\_path]
[-i include\_pattern] [-x exclude\_pattern] command [parameters]

## Parameters

Parameter | Description
--- | ---
-d  |   Debug -- print generated command to stdout, but don't execute it.  Implies -v (verbose).
-v  |   Be verbose.  Displays generated commands to stdout.
-s  |   Generate system include paths. See [System Include Files](#system-includes).
-n  |   Don't include `-I` or `-D` parameters in the generated command. This can be useful when using the script to execute "normal" commands (e.g., grep) that don't take such parameters.
-p build\_path  |   Specifies the path to a compilation database in JSON format.  It can be either an absolute path to a compilation database, or a directory (which will be searched for a compile\_commands.json file).  If omitted, the current directory is used.
-i include_pattern | File paths matching include_pattern are included in generated commands.  May be specified multiple times.  If omitted, all files in the compilation database are included.
-x exclude_pattern | File paths matching exclude_pattern are not included in generated commands.  May be specified multiple times.  All exclude_patterns are matched after any include patterns.  
command | Specifies the command to run against each file.  (See [below](#generated-command-format) for details on how the generated command line is constructed).
parameters | Any parameters for the specified command.  Note that you may need to quote the parameters if they include quotes themselves to avoid [quote removal](http://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_07).


## Environment Variables
If the `-s` option is specified, the value of `${CXX}` is used as the name of the compiler.  (If `${CXX}` is not defined, the default is `g++`).

## Notes
The generated command first changes to the original build directory before executing the specified command, so specifying [command] using a relative path is generally a mistake.  Instead use an absolute path, or make sure that [command] can be found using the `PATH` environment variable.

### Generated command format
The script generates a command line of the form

`
cd {directory}; [command] [parameters] -I .. -D .. {file}
`

The clang tools require a slightly different format -- if a clang tool is specified for [command], the generated command format is:

`
cd {directory}; [command] {file} -- [parameters] -I .. -D .. 
`

<a id="system-includes"></a>

### System Include Files
Some of the tools that can be scripted with this command work better (sometimes much better) if they can see all the include files used in the original compilation. If the `-s` flag is specified, the system include paths are appended to any include paths from the original compile command.

The system include paths are:

- Any paths specified using the `-isystem` compiler flag.  (See [System Headers - The C Preprocessor](https://gcc.gnu.org/onlinedocs/cpp/System-Headers.html) for why you might want to use the `isystem` flag).  As with the compiler's `-isystem` flag, any directories specified are searched *after* all directories specified using the `-I` flag, regardless of where it occurs on the command line.

- The default compiler search paths are appended to the generated command line.  The compiler search paths are determined by parsing the output of
`${CXX} -E -x c++ - -v 2>&1 1>/dev/null </dev/null`


See [this post](/blog/2016/04/07/mo-static) for more information.
