# pvs2csv.pl
{:.no_toc}

This script takes the output PVS-Studio (`pvs-studio-analyzer analyze`) and formats it in csv format.

## Usage
pvs2csv.pl [-r relative_path] [file]

## Parameters

|Parameter | Description
|--- | ---
|-r relative_path | If specified, relative_path is stripped from the output.  This makes it easier to compare results between different directories.
|file | Specifies the input file.  If omitted, input is read from stdin.

## Notes
Some people have experienced problems with the output from PVS-Studio, not realizing that the output is not intended to be used directly, but that it should first be post-processed using the included `plog-converter` utility.  Note that the pvs2csv.pl script does *not* require the use of `plog-converter`, but processes the direct output from `pvs-studio-analyzer analyze`.

Leading `../` and `./` strings are also stripped from file paths.

See [this post](/blog/2016/11/12/even-mo-static) for more information.
