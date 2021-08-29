#!/usr/bin/env perl

use strict;
use warnings;

#<p id="dex-page-types">
#</p>

sub contains {
	my ($needle, @haystack) = @_;
	return scalar grep { $_ eq $needle } @haystack;
}

sub filter {
	my $inside = 0;
	my @buffer;
	while (<>) {
		next unless $inside or /"dex-page-types"/;
		#s!^    <dd><p>(?<description>[^<]*)</p></dd>$!$+{description}! and !contains($_, @buffer) and print, push @buffer, $_;
		$inside = !m!^</p>!;
	}
}

filter();


