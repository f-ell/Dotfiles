#!/usr/bin/perl
use warnings;
use strict;

my $C = 'True' if $ARGV[0] eq 'cpu';
my $M = 'True' if $ARGV[0] eq 'mem';
# use `du` to get use and maximum cap mounted on /
# my $S = 'True' if $ARGV[0] eq 'sto';

open(FH, '</proc/meminfo') or die("$!");
  my $MemTotal  = <FH>;
  <FH>;
  my $MemUsed   = <FH>;
close(FH) or die("$!");

($MemTotal) = $MemTotal =~ /^MemTotal:\s+(\d+) kB/;
($MemUsed)  = $MemUsed  =~ /^MemAvailable:\s+(\d+) kB/;
$MemUsed = ($MemTotal - $MemUsed) / 1024;
$MemTotal /= 1024;

# `free -m` =~ /Mem:\s+(\d+)\s+(\d+)/; # maybe switch to /proc/meminfo (needs unit conversion)
# my $MemTotal  = $1;
# my $MemUsed   = $2;

if ($C or $M) {
  my $String  = '  ';
  $String     = ' ' if $MemUsed >= 1000;
  $String     = ''  if $MemUsed >= 10000;

  printf "$String" if $C;
  printf "$String%.f MiB / %.f MiB\n", $MemUsed, $MemTotal if $M;
}

# idea: negative spacing in front of fsused and fstotal depending on length
# difference

