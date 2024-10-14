#!/usr/bin/perl
use warnings;
use strict;
$\ = "\n";

open FH, '-|', 'df' or die $!;
while (<FH>) {
    next unless /\/$/;
    @ARGV = split /\s+/;
    last;
}
close FH or die $!;

my %dskinfo = ( fs => shift, size => shift, used => shift );
printf "%.1f GiB\n", $dskinfo{used} / ( 1024**2 )
