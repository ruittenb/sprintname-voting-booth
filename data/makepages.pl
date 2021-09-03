#!/usr/bin/env perl

use strict;
use warnings;
use POSIX qw(mktime strftime);

use constant TWO_WEEKS => 60 * 60 * 24 * 14; # Get ready for a surprise!

my ($sec, $min, $hour, $mday, $mon, $year) = (0, 0, 0, 25, 6, 123); # 2023-07-04T00:00:00.000+02:00
my $date = mktime($sec, $min, $hour, $mday, $mon, $year);

my $id = 199;
my $generation = "ii";

for ("A" .. "Z") {
    next if /U/;

	my $datestr = strftime("%Y-%m-%dT00:00:00.000+02:00", localtime $date);
    print <<"    _end_";
      },
      {
        "generation": "$generation",
        "id": $id,
        "letter": "$_",
        "open": true,
        "startDate": "$datestr"
    _end_

    $id++;
    $date += TWO_WEEKS;
}



