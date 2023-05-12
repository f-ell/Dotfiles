#!/usr/bin/perl
use warnings; use strict; $\ = "\n";

my %meminfo = ();
open FH, '-|', 'df' or die $!;
  while (<FH>) {
    next unless /\/$/;
    @ARGV = split /\s+/;
    last;
  }
close FH or die $!;

my %dskinfo = ( fs => shift, size => shift, used => shift );
printf "%.1f GiB / %.f GiB %s\n", $dskinfo{used}/(1024**2), $dskinfo{size}/(1024**2);
