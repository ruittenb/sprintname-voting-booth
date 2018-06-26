#!/usr/bin/env perl
#
# weed out double descriptions

use strict;
use warnings;

foreach (<>) {
	s/(?<label>"description"): "(?<value>[^"]+)\s*\k<value>"/$+{label}: "$+{value}"/;
	print;
}
