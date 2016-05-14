# cppcheck2csv.pl
{:.no_toc}

This script takes the output from cppcheck and formats it in csv format.

## Usage
cppcheck2csv.pl [-r relative_path] [file]

## Parameters

Parameter | Description
--- | ---
-r relative_path | If specified, relative_path is stripped from the output.  This makes it easier to compare results between different directories.
file | Specifies the input file.  If omitted, input is read from stdin.

## Notes
Leading `../` and `./` strings are also stripped from file paths.

See [this post](/blog/2016/04/07/mo-static) for more information.
