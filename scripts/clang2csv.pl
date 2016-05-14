#!/usr/bin/perl
#
# Copyright 2016 by Bill Torpey. All Rights Reserved.
# This work is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 United States License.
# http://creativecommons.org/licenses/by-nc-nd/3.0/us/deed.en
#
use strict;

###############################################################
# trims quotes, leading & trailing spaces from a string
sub trim
{
   my @out = @_;
   for (@out) {
      s/^\s+//;
      s/\s+$//;
      s/"//g;
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
   #($_ =~ 'warning:|note:') || next;                     # skip lines that are not clang warnings
   ($_ =~ 'warning:') || next;                            # skip lines that are not clang warnings
   my @tokens = split(" ", $_);
   my @filename = split(':', shift @tokens);
   my $filename = $filename[0] . ':' . $filename [1];
   defined $relative_path && $filename =~ s/$relative_path//;
   $filename = trim($filename);
   my $message = trim(join(" ", @tokens));
   print "\"$filename\",\"$message\"\n";
}

close(INFILE);

0;
