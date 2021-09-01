#!/usr/bin/env perl

use strict;
use warnings;
use POSIX qw(mktime strftime);

use constant TWO_WEEKS => 60 * 60 * 24 * 14; # Get ready for a surprise!

my ($sec, $min, $hour, $mday, $mon, $year) = (0, 0, 0, 30, 7, 122); # 2022-08-30
my $date = mktime($sec, $min, $hour, $mday, $mon, $year);

my $id = 175;

for ("A" .. "Z") {
    next if /I/ || /Y/;

	my $datestr = strftime("%Y-%m-%dT00:00:00.000+02:00", localtime $date);
    print <<"    _end_";
      },
      {
        "generation": "i",
        "id": $id,
        "letter": "$_",
        "open": true,
        "startDate": "$datestr"
    _end_

    $id++;
    $date += TWO_WEEKS;
}



