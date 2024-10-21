#!/usr/bin/perl
use warnings;
use strict;
$\ = "\n";

use List::Util      qw(max);
use List::MoreUtils qw(firstidx);

my @sensors = `sensors`;
my @smi     = `nvidia-smi -q -d TEMPERATURE`;

my $i = firstidx( sub { /Core \d+/ }, @sensors );
my $ctemp =
  max( map( { /Core \d+:\s+\+(\d+)/ } @sensors[ $i .. $i + 7 ] ) );
my $gtemp =
  ( $smi[ firstidx( sub { /GPU Current Temp/ }, @smi ) ] =~ /(\d+) C$/ )[0];

print("${ctemp}°C|${gtemp}°C");
