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

 local *INFILE;
 if (defined($ARGV[0])) {
     open(INFILE, "<:crlf", "$ARGV[0]") or die "Cant open $ARGV[0]\n";
 }
 else {
     *INFILE = *STDIN;
 }


while (<INFILE>) {
   ($_ =~ '^\[') || next;                     # skip lines that are not cppcheck warnings
   my @tokens = split("]:", $_);
   my $filename = trim(shift @tokens);
   $filename =~ s/^\.\.\///;                  # remove leading "../" from path 
   defined $relative_path && $filename =~ s/$relative_path//g;
   my $message = trim(join(" ", @tokens));
   print "\"$filename\",\"$message\"\n";
}

close(INFILE);

0;
