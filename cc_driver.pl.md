##NAME

cc_driver.pl -- invoke a command on each target in a compilation database

## SYNOPSIS

cc\_driver.pl [-v] [-s] [-p build\_path]
[-i include\_pattern] [-x exclude\_pattern] command [parameters]

## DESCRIPTION

cc_driver.pl parses a [compilation database](http://clang.llvm.org/docs/JSONCompilationDatabase.html), and executes a specified command for each matching file in the database.  It generates a command that includes the `-I` and `-D` parameters used in the original compilation.

-v      Be verbose.  Displays generated commands to stdout.

-s      Generate system include paths. See [SYSTEM INCLUDE FILES][].

-p build\_path
        Specifies the path to a compilation database in JSON format.  It can be either an absolute path to a compilation database, a directory (which will be searched for a compile\_commands.json file).  If omitted, the current directory is used.

The generated command first changes to the original build directory before executing the specified command, so specifying [command] using a relative path is generally a mistake.  Instead use an absolute path, or make sure that [command] can be found using the `PATH` environment variable.

The script generates a command line of the form

`
cd {directory}; [command] [parameters] -I .. -D .. {file}
`

The clang tools require a slightly different format -- if a clang tool is specified for [command], the generated command format is:

`
cd {directory}; [command] {file} -- [parameters] -I .. -D .. 
`

## SYSTEM INCLUDE FILES
Some of the tools that can be scripted with this command work better (sometimes much better) if they can see all the include files used in the original compilation. If the `-s` flag is specified, the system include paths are appended to any include paths from the original compile command.

The system include paths are:

- Any paths specified using the `-isystem` compiler flag.  (See [System Headers - The C Preprocessor](https://gcc.gnu.org/onlinedocs/cpp/System-Headers.html) for why you might want to use the `isystem` flag).  As with the compiler's `-isystem` flag, any directories specified are searched *after* all directories specified using the `-I` flag, regardless of where it occurs on the command line.

- The default compiler search paths are appended to the generated command line.  The compiler search paths are determined by parsing the output of
`${CXX} -E -x c++ - -v 2>&1 1>/dev/null </dev/null`

## EXAMPLES

To greet the entire world (note: the world's reciprocal behavior is undefined):

    hello

To greet the reader of this post and make them feel welcome:

    hello 'Spin reader'


## DIAGNOSTICS

Returns 0 on successful greeting.

## ENVIRONMENT
${CXX}      If the `-s` option is specified, the value of `${CXX}` is used as the name of the compiler.  (If `${CXX}` is not defined, the default is `g++`).


## AUTHOR

Bill Torpey <wallstprog@gmail.com>

## SEE ALSO

<http://clang.llvm.org/docs/JSONCompilationDatabase.html>
<http://clang.llvm.org/docs/JSONCompilationDatabase.html>
<https://gcc.gnu.org/onlinedocs/cpp/System-Headers.html>

