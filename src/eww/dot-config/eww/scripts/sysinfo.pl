#!/usr/bin/perl
use warnings;
use strict;
$\ = "\n";

use List::Util      qw(max sum);
use List::MoreUtils qw(firstidx);

my sub cpu_util() {
  (`top -bn1`)[2] =~ /(\d+)\.\d id,/;
  return sprintf( '%3d%%', 100 - $1 );
}

my sub battery() {
  my $bat0 = `python -c '
from openrazer.client import DeviceManager as dm
print(dm().devices[0].battery_level)
  '`;
  return sprintf( '%3d%%', $bat0 );
}

my sub ram() {
  my %meminfo;

  open( FH, '<', '/proc/meminfo' ) || die($!);
  for ( grep( /^Mem/, <FH> ) ) {
    /^(Mem.+?):\s+(\d+) kB$/;
    $meminfo{ lc($1) } = $2 / 1024;
  }
  close(FH) || die($!);

  return sprintf( "%5d MiB", $meminfo{memtotal} - $meminfo{memavailable} );
}

my sub gpu_util() {
  ( grep( /Gpu/, `nvidia-smi -q -d UTILIZATION` ) )[0] =~ /(\d+) %$/;
  return sprintf( '%3d%%', $1 );
}

my sub vram() {
  ( grep( /Used/, `nvidia-smi -q -d MEMORY` ) )[0] =~ /(\d+) MiB$/;
  return sprintf( '%5d MiB', $1 );
}

my sub cpu_temp() {
  my @sensors = `sensors`;
  my $i       = firstidx( sub { /Core \d+/ }, @sensors );
  my $cpu =
    max( map( /Core \d+:\s+\+(\d+)/, @sensors[ $i .. $i + 7 ] ) );

  return sprintf( '%2s°C', $cpu );
}

my sub gpu_temp() {
  my $gpu =
    ( ( grep( /GPU Current Temp/, `nvidia-smi -q -d TEMPERATURE` ) )[0] =~
      /(\d+) C$/ )[0];

  return sprintf( '%2s°C', $gpu );
}

my sub disk() {
  $_ = ( split( /\s+/, ( grep( m{/$}, `df` ) )[0] ) )[2];
  return sprintf( '%.1f GiB', $_ / ( 1024**2 ) );
}

print <<~EOF
    SYS ${\cpu_util()} | ${\ram()}
    GPU ${\gpu_util()} | ${\vram()}
    TMP ${\cpu_temp()} | ${\gpu_temp()}
    BTR ${\battery()}
    DSK ${\disk()}
    EOF
  ;
