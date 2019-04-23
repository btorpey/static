#!/usr/bin/perl
#
# Copyright 2018 by Bill Torpey. All Rights Reserved.
# This work is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 United States License.
# http://creativecommons.org/licenses/by-nc-nd/3.0/us/deed.en
#

#
# This script takes output from PVS-Studio plog-converter and converts it to format used for other
# tools.
#

use strict;

use Text::ParseWords;

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

my @cols;
# main loop

while (<INFILE>) {
   ($_ =~ 'Total messages:') && next;
   ($_ =~ 'Filtered messages:') && next;

   @cols = Text::ParseWords::parse_line(',', 0, $_);
   if (@cols != 0) {
      my $type = $cols[1];
      my $msg = $cols[3];
      my $filename = trim($cols[6]);
      defined $relative_path && $filename =~ s/$relative_path//;
      my $lineno = $cols[5];

      my @ids = Text::ParseWords::parse_line(',', 0, $cols[2]);
      my $id = substr($ids[1], 1, -1);
      next if ($id eq 'Renew');

      printf("\"$filename:$lineno\",\"$type: $id $msg\"\n");
   }
}

close(INFILE);

0;
