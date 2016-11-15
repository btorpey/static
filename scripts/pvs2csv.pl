#!/usr/bin/perl
#
# Copyright 2016 by Bill Torpey. All Rights Reserved.
# This work is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 United States License.
# http://creativecommons.org/licenses/by-nc-nd/3.0/us/deed.en
#
use strict;

###############################################################
# trims quotes, leading & trailing spaces, etc. from a string
sub trim
{
   my @out = @_;
   for (@out) {
      s/^\s+//;
      s/\s+$//;
      s/"//g;
      s/\[//g;
      s/\]//g;
   }
   return wantarray ? @out : $out[0];
}

###############################################################
# get cmd line args
use Getopt::Long qw(:config pass_through);
# relative path to strip from full path
my $relative_path;
GetOptions('r=s' => \$relative_path);

# open named file, or use stdin
 local *INFILE;
 if (defined($ARGV[0])) {
     open(INFILE, "<:crlf", "$ARGV[0]") or die "Cant open $ARGV[0]\n";
 }
 else {
     *INFILE = *STDIN;
 }

# main loop
while (<INFILE>) {
   my $line = $_;
   my $i = index($line, "(");
   my $j = index($line, "):", $i);
   my $filename = substr($line, 0, $i);
   #$filename =~ s/^\.\.\///;                  # remove leading "../" from path 
   my $lineno = substr($line, $i+1, ($j-$i)-1);
   my $errStr = substr($line, $j+3);
   chomp($errStr);
   print "\"$filename:$lineno\",\"$errStr\"\n";
}

close(INFILE);

0;
