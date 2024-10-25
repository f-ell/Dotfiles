#!/usr/bin/perl
use warnings;
use strict;
$\ = "\n";

use List::Util      qw(max sum);
use List::MoreUtils qw(firstidx);

my sub cpu() {
  (`top -bn1`)[2] =~ /(\d+)\.\d id,/;
  return sprintf( '%3d%%', 100 - $1 );
}

my sub ram() {
  my %meminfo;

  open( FH, '<', '/proc/meminfo' ) || die($!);
  for ( grep( /^Mem/, <FH> ) ) {
    /^(Mem.+?):\s+(\d+) kB$/;
    $meminfo{ lc($1) } = $2 / 1024;
  }
  close(FH) || die($!);

  return sprintf( "%4d MiB", $meminfo{memtotal} - $meminfo{memavailable} );
}

my sub gpu() {
  ( grep( /Gpu/, `nvidia-smi -q -d UTILIZATION` ) )[0] =~ /(\d+) %$/;
  return sprintf( '%3d%%', $1 );
}

my sub vram() {
  ( grep( /Used/, `nvidia-smi -q -d MEMORY` ) )[0] =~ /(\d+) MiB$/;
  return sprintf( '%4d MiB', $1 );
}

my sub temperature() {
  my @sensors = `sensors`;
  my $i       = firstidx( sub { /Core \d+/ }, @sensors );
  my $cpu =
    max( map( /Core \d+:\s+\+(\d+)/, @sensors[ $i .. $i + 7 ] ) );

  my $gpu =
    ( ( grep( /GPU Current Temp/, `nvidia-smi -q -d TEMPERATURE` ) )[0] =~
      /(\d+) C$/ )[0];

  return sprintf( '%2s°C | %2s°C', $cpu, $gpu );
}

my sub disk() {
  $_ = ( split( /\s+/, ( grep( m{/$}, `df` ) )[0] ) )[2];
  return sprintf( '%.1f GiB', $_ / ( 1024**2 ) );
}

print <<~EOF
    SYS ${\cpu()} | ${\ram()}
    GPU ${\gpu()} | ${\vram()}
    TMP ${\temperature()}
    DSK ${\disk()}
EOF
  ;
