#!/usr/bin/env perl 

use strict;
use warnings;

my $START = 702;
my $started = 0;
my $current;
my @description;

open POKEDEX, '<', '../pokedex.json' or die "Cannot open pokedex: $!";

foreach (<POKEDEX>) {
	if (/^    "id": $START\b/) {
		$started++;
		# we encounter "id" before the corresponding description
		$current = $START + 1;
	}
	if (/^    "description": "/ and $started) {
		@description = map { chomp; $_ } `cat $current.html`;
		s/^(?<key>    "description"): ".*",/$+{key}: "@description",/;
		$current++;
	}
	print;
}



