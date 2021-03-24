#!/usr/bin/perl
#
# Copyright 2016 by Bill Torpey. All Rights Reserved.
# This work is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 United States License.
# http://creativecommons.org/licenses/by-nc-nd/3.0/us/deed.en
#
use strict;

use File::Spec;

###############################################################
# get compiler's default include path
sub getCXX
{
   # get compiler command
   my $compiler = $ENV{'CXX'};
   if (!defined $compiler) {
      $compiler = "g++";
   }
   
   $compiler = trim(`which $compiler`);

   return $compiler;
}

sub getCC
{
   # get compiler command
   my $compiler = $ENV{'CC'};
   if (!defined $compiler) {
      $compiler = "gcc";
   }
   
   $compiler = trim(`which $compiler`);
   
   return $compiler;
}

sub getCXXIncludes
{
   # get compiler command
   my $compiler = getCXX();
   my @includes;
   my $capture = 0;
   my @lines = `$compiler  -E -x c++ - -v 2>&1 1>/dev/null </dev/null`;
   for my $line (@lines) {
      if ($line =~ /#include <...> search starts here:/) {
         $capture = 1;
      }
      elsif ($line =~ /End of search list./) {
         return join(" ", @includes);
      }
      else {
         if ($capture == 1) {
            $line =~ s/\(framework directory\)//;       # xcode silliness
            my $include = "-I" . trim($line);
            push @includes, $include;
         }
      }
   }
}

###############################################################
# trims commas, quotes, leading & trailing spaces from a string
sub trim
{
   my @out = @_;
   for (@out) {
      s/^\s+//;
      s/\s+$//;
      s/"//g;
      s/,//g;
   }
   return wantarray ? @out : $out[0];
}

###############################################################
# get cmd line args
use Getopt::Long qw(:config pass_through bundling);
# location and/or name of compile db
my $build_path = "compile_commands.json";
GetOptions('p=s' => \$build_path);
# debug mode
my $debug = 0;
GetOptions('d' => \$debug);
# whether to generate command a la compiler
my $no_params = 0;
GetOptions('n' => \$no_params);
# whether to include system headers
my $include_sys_headers = 0;
GetOptions('s' => \$include_sys_headers);
# verbose?
my $verbose = 0;
GetOptions('v' => \$verbose);
# match file path/name?
my @match;
GetOptions('i=s' => \@match);
my $match;
if ((scalar @match) > 0) {
   $match = join("|", @match);
}
my @exclude;
GetOptions('x=s' => \@exclude);
my $exclude;
if ((scalar @exclude) > 0) {
   $exclude = join("|", @exclude);
}
# debug implies verbose
($debug == 1) && ($verbose = 1);

($verbose == 1) && print "parameters=@ARGV\n";


###############################################################
# main

my $compile_commands;
if (-f $build_path) {
   $compile_commands = $build_path;
}
elsif(-d $build_path) {
    $compile_commands = $build_path . "/compile_commands.json";
}
else {
   die "$build_path doesn't exist!";
}

if (-e $build_path) {
}
else {
   die "$build_path doesn't exist!";
}

my $compiler_includes;
if ($include_sys_headers == 1) {
   $compiler_includes = getCXXIncludes();
   if ($verbose == 1) {
      print "system includes = $compiler_includes\n";
   }
}

print " ARGV[0] = $ARGV[0]\n";

open(INFILE, "<:crlf", "$compile_commands") or die "Cant open $compile_commands\n";

my @params;
# note that directories specified w/"-isystem" are searched after directories specifed w/"-I"
# (see https://gcc.gnu.org/onlinedocs/gcc/Directory-Options.html)
my @system_includes;
my $directory;
my $file;
my $vol;
my $full_path;
my $cc = getCC();
my $cxx = getCXX();

while (<INFILE>) {
   my @tokens = split(" ", $_);
   if ($tokens[0] eq '{') {
      # start of an entry
      @params  = ();
      @system_includes  = ();
      $directory = "";
      $file      = "";
   }
   elsif ($tokens[0] eq '"command":') {
      if ($no_params == 0) {
         for my $i (2 .. $#tokens) {
            if ($tokens[$i] eq "-D") {
               push @params, "-D" . $tokens[++$i];
            }
            elsif (substr($tokens[$i], 0, 2) eq "-D") {
               push @params, $tokens[$i];
            }
            elsif ($tokens[$i] eq "-I") {
               push @params, "-I" . $tokens[++$i];
            }
            elsif (substr($tokens[$i], 0, 2) eq "-I") {
               push @params, $tokens[$i];
            }
            elsif (substr($tokens[$i], 0, 5) eq "-std=") {
               # clang & pvs both invoke the compiler as part of static analysis, which needs to know the standard,
               # esp. when the compiler defaults to c++1x mode, but code being analyzed is written to a different (older) standard
               if ($ARGV[0] !~ /cppcheck/) {
                  # cppcheck doesn't like this flag
                  push @params, $tokens[$i];
               }
            }
            elsif (substr($tokens[$i], 0, 8) eq "-isystem") {
               push @system_includes, "-I " . $tokens[++$i];
               # if ($ARGV[0] !~ /cppcheck/) {
               #    push @system_includes, "-I " . $tokens[++$i];
               # }
            }
            elsif ($tokens[$i] eq "-fstack-usage") {
               # skip it -- not material to analysis, and clang errors out
            }
            elsif ($tokens[$i] eq "-frecord-gcc-switches") {
               # skip it -- not material to analysis, and clang errors out
            }
         }
      }
   }
   elsif ($tokens[0] eq '"file":') {
      my $path = trim($tokens[1]);
      ($vol,$directory,$file) = File::Spec->splitpath($path);
      $full_path = File::Spec->catpath( $vol, $directory, $file );

#      print "path=$path\n";
#      print "vol=$vol\n";
#      print "directory=$directory\n";
#      print "file=$file\n";
#      print "full_path=$full_path\n";

   }
   elsif (($tokens[0] eq '},') || ($tokens[0] eq '}')) {
      # end of an entry
      my $params = join(" ", @params);
      my $system_includes = join(" ", @system_includes);
      my $cmd;
      if ($ARGV[0] =~ /clang/) {
         # clang tools use a specific command line format
         $cmd = "cd $directory;@ARGV $file -- $params $system_includes $compiler_includes";
      }
      elsif ($ARGV[0] =~ /pvs-studio-analyzer/) {
         $cmd = "cd $directory;@ARGV --cc $cc --cxx $cxx --source-file $file --cl-params $params $system_includes $compiler_includes $file ";
      }
      elsif ($ARGV[0] =~ /pvs-studio/) {
         $cmd = "cd $directory;@ARGV --source-file $file --cl-params $params $system_includes $compiler_includes $file ";
      }
      elsif ($ARGV[0] =~ /cppcheck/) {
         # pass full path to cppcheck
         $cmd = "cd $directory;@ARGV $params $system_includes $compiler_includes $full_path";
      }
      else {
         # else assume that command format is same as normal compiler command
         $cmd = "cd $directory;@ARGV $params $system_includes $compiler_includes $file";
      }
      # include/exclude file based on -i/-x param
      my $run = 1;
      ((defined $match)   && ($full_path !~ /$match/))   && ($run = 0);
      ((defined $exclude) && ($full_path =~ /$exclude/)) && ($run = 0);
      if ($run == 1) {
         my $output;
         ($verbose == 1) && print "$cmd\n";
         if ($debug != 1) {
            $output = `$cmd 2>&1`;
            print "$output\n" if $output;
            my $rc = $?;
            if ($rc != 0) {
               die "$cmd returned $rc!";
            }
         }
      }
      # exit on signal
      ($? & 127) && exit;
   }
}

close(INFILE);

0;
