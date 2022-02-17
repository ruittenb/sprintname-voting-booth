#!/usr/bin/env perl

use strict;
use warnings;
use POSIX qw(mktime strftime);

use constant TWO_WEEKS => 60 * 60 * 24 * 14; # Get ready for a surprise!

my ($sec, $min, $hour, $mday, $mon, $year) = (0, 0, 0, 25, 5, 124); # 2024-06-25T00:00:00.000+02:00
my $date = mktime($sec, $min, $hour, $mday, $mon, $year);

my $id = 224;
my $generation = "iii";

for ("A" .. "Z") {
    next if /[IQUVZ]/;

    $date += TWO_WEEKS;
	my $datestr = strftime("%Y-%m-%dT00:00:00.000%z", localtime $date);
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
}



