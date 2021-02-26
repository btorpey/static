#!/usr/bin/perl
#
# Copyright 2020 by Bill Torpey. All Rights Reserved.
# This work is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 United States License.
# http://creativecommons.org/licenses/by-nc-nd/3.0/us/deed.en
#
use strict;

use Cwd qw(abs_path cwd);
use File::Temp qw/ :POSIX/;
use File::Basename;

sub readOptions
{
   my $file = shift;
#   print("readOptions from $file\n");

   my $temp;
   open(my $fh, '<', $file) or die "cannot open file $file";
   while(<$fh>) {
      chomp;
      ($_ =~ '^#') && next;                            # skip comments
      $temp .= " $_";
   }
   close($fh);

   return $temp;
}


# its a very good idea to include compiler builtin definitions
my $tempFile = tmpnam();
my $rc = system("cpp -dM </dev/null 2>/dev/null >$tempFile");

my $scriptDir = dirname(__FILE__);

my $srcDir = $ENV{'SRC_ROOT'};
my $srcDir = abs_path($srcDir);
my $dir = cwd();
# do like clang-tidy and look for .cppcheckrc in source file directory and its parents
my $options;
while (length($dir) > length($srcDir)) {
   if (-e "$dir/.cppcheckrc") {
      $options = readOptions("$dir/.cppcheckrc");
      last;
   }
   else {
      $dir = dirname($dir);
   }
}

my $cmd = "cppcheck --inline-suppr --include=$tempFile --template=\"[{file}:{line}]: ({severity}) {message} [{id}]\" $options @ARGV";
print("$cmd\n");
system("$cmd");
