#!/usr/bin/perl
use warnings; use strict; $\ = "\n";

my %meminfo = ();
open FH, '<', '/proc/meminfo' or die $!;
  while (<FH>) {
    @ARGV = split /:\s+/;
    $ARGV[1] =~ s/\skB$//;
    $meminfo{+shift} = $ARGV[1] / 1024;
  }
close FH or die $!;

printf "%.f MiB / %.f MiB\n", $meminfo{MemTotal} - $meminfo{MemAvailable}, $meminfo{MemTotal};
