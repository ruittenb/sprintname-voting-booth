#!/usr/bin/env perl

use strict;
use warnings;

##<dt class="dex-flavor-generation"><img alt="Generation 7" src="/static/pokedex/images/versions/generation-7.png" title="Generation 7" /></dt>
#<dd>
#  <dl>
#    <dt><img alt="Moon" src="/static/pokedex/images/versions/moon.png" title="Moon" /></dt>
#    <dd><p>Although this Pokémon is not especially rare, its glittering, jewel-draped body draws attention from people.</p></dd>
#    <dt><img alt="Ultra Sun" src="/static/pokedex/images/versions/ultra-sun.png" title="Ultra Sun" /></dt>
#    <dd><p>Some say that deep beneath the surface of the world, a pack of Carbink live with their queen in a kingdom of jewels.</p></dd>
#  </dl>
#</dd>

sub filter {
	my $inside = 0;
	my @buffer;
	while (<>) {
		next unless $inside or /"dex-flavor-generation"/;
		$inside or $inside++, @buffer = (), next;
		#s!^    <dd><p>(?<description>[^<]*)</p></dd>$!$+{description}! and print, next;
		if (s!^    <dd><p>(?<description>[^<]*)</p></dd>$!$+{description}! and !grep($_, @buffer)) {
			print;
			push @buffer, $_;
			next;
		}
		$inside = !m!^</dd>!;
	}
}

filter();

