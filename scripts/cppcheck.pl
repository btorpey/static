#!/usr/bin/perl
#
# Copyright 2020 by Bill Torpey. All Rights Reserved.
# This work is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 United States License.
# http://creativecommons.org/licenses/by-nc-nd/3.0/us/deed.en
#
use strict;

use Cwd;
use File::Temp qw/ :POSIX/;
use File::Basename;

sub readOptions
{
   my $file = shift;

   my $temp;
   open(my $fh, '<', $file) or die "cannot open file $file";
   while(<$fh>) {
      chomp;
      $temp .= " $_";
   }
   close($fh);

   return $temp;
}


# its a very good idea to include compiler builtin definitions
my $tempFile = tmpnam();
my $rc = system("cpp -dM </dev/null 2>/dev/null >$tempFile");

my $scriptDir = dirname(__FILE__);

my $options = $ENV{'CPPCHECK_OPTS'};
if ($options eq "") {
   my $cwd = getcwd();
   my $srcRoot = $ENV{'SRC_ROOT'};
   my $srcRoot2 = $ENV{'SRC_ROOT2'};
   if (-e "$srcRoot/.cppcheckrc") {
      $options = readOptions("$srcRoot/.cppcheckrc");
   }
   elsif (-e "$srcRoot2/.cppcheckrc") {
      $options = readOptions("$srcRoot2/.cppcheckrc");
   }
   elsif (-e "~/.cppcheckrc") {
      $options = readOptions("~/.cppcheckrc");
   }
   elsif (-e "$scriptDir/.cppcheckrc") {
      $options = readOptions("$scriptDir/.cppcheckrc");
   }
}

my $cmd = "cppcheck --include=$tempFile $options @ARGV";
print("$cmd\n");
system("$cmd");
